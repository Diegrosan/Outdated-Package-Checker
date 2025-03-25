#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present Diegro

SCRIPT_DIR="$(dirname "$0")"
LIBRETRO_CORES_DIR="$SCRIPT_DIR/packages/sx05re/libretro"

OUTPUT_FILE="list.txt"
OUTPUT_FILE2="listupdate.txt"

> "$OUTPUT_FILE"
> "$OUTPUT_FILE2"

echo -n "./package_bump.sh --packages \"" >> "$OUTPUT_FILE2"

# Language selection
LANG=$(echo "$LANG" | cut -c1-2)

# Translation function
translate() {
    local en="$1"
    local pt="$2"
    local es="$3"
    
    case "$LANG" in
        pt) echo "$pt" ;;
        es) echo "$es" ;;
        en) echo "$en" ;;
        *) echo "$en" ;;
    esac
}

# Messages
checking_msg=$(translate \
    "Checking for outdated packages..." \
    "Verificando pacotes desatualizados do packages..." \
    "Verificando paquetes desactualizados..."
)

error_commit_msg=$(translate \
    "ERROR: Could not get the latest commit" \
    "ERRO: Não foi possível obter o último commit" \
    "ERROR: No se pudo obtener el último commit"
)

checking_pkg_msg=$(translate \
    "Checking %s... " \
    "Verificando %s... " \
    "Verificando %s... "
)

updated_msg=$(translate \
    "Up to date" \
    "Atualizado" \
    "Actualizado"
)

outdated_msg=$(translate \
    "Possibly outdated" \
    "Possivelmente desatualizado" \
    "Posiblemente desactualizado"
)

no_site_msg=$(translate \
    "%s: PKG_SITE not defined" \
    "%s: PKG_SITE não definido" \
    "%s: PKG_SITE no definido"
)

no_git_hash_msg=$(translate \
    "%s: Version is not a git hash (%s)" \
    "%s: Versão não é um hash git (%s)" \
    "%s: La versión no es un hash git (%s)"
)

no_mk_file_msg=$(translate \
    "%s: package.mk file not found" \
    "%s: Arquivo package.mk não encontrado" \
    "%s: Archivo package.mk no encontrado"
)

completed_msg=$(translate \
    "Check completed. Results saved to %s" \
    "Verificação concluída. Resultados salvos em %s" \
    "Verificación completada. Resultados guardados en %s"
)

echo "$checking_msg" | tee -a "$OUTPUT_FILE"

clean_url() {
    local url="$1"
    url=$(echo "$url" | sed -e 's|^https://https://|https://|' -e 's/^"//' -e 's/"$//' -e 's|\.git$||')
    echo "$url"
}

get_commit_date() {
    local repo_url="$1"
    local commit_hash="$2"
    
    # Try to get date from GitHub API if it's a GitHub repository
    if [[ "$repo_url" =~ github.com ]]; then
        local repo_path=$(echo "$repo_url" | sed -e 's|https://github.com/||' -e 's|/$||')
        local api_url="https://api.github.com/repos/$repo_path/git/commits/$commit_hash"
        
        local date=$(curl -s "$api_url" | jq -r '.committer.date' 2>/dev/null)
        if [ "$date" != "null" ] && [ -n "$date" ]; then
            echo "$date" | cut -d'T' -f1
            return
        fi
    fi

    # Fallback method using git clone (slower but works for any git repo)
    local temp_dir=$(mktemp -d)
    if git clone --quiet --filter=blob:none --no-checkout "$repo_url" "$temp_dir" &>/dev/null; then
        (
            cd "$temp_dir"
            git fetch --quiet origin "$commit_hash" 2>/dev/null
            date=$(git show -s --format=%cd --date=short "$commit_hash" 2>/dev/null)
            if [ -n "$date" ]; then
                echo "$date"
            else
                echo "$(translate "Date unavailable" "Data indisponível" "Fecha no disponible")"
            fi
        )
    else
        echo "$(translate "Date unavailable" "Data indisponível" "Fecha no disponible")"
    fi
    
    rm -rf "$temp_dir" &>/dev/null
}

check_repo_status() {
    local pkg_name="$1"
    local repo_url="$2"
    local current_commit="$3"

    printf "$checking_pkg_msg" "$pkg_name" | tee -a "$OUTPUT_FILE"
    
    # Get latest commit hash
    local latest_commit=$(timeout 15s git ls-remote "$repo_url" HEAD 2>/dev/null | cut -f1)
    
    if [ -z "$latest_commit" ]; then
        echo "$error_commit_msg" | tee -a "$OUTPUT_FILE"
        return
    fi

    # Get dates
    local current_date=$(get_commit_date "$repo_url" "$current_commit")
    local latest_date=$(get_commit_date "$repo_url" "$latest_commit")

    if [ "$current_commit" = "$latest_commit" ]; then
        echo "$updated_msg" | tee -a "$OUTPUT_FILE"
        echo "  $(translate "Commit" "Commit" "Commit"): $current_commit ($current_date)" | tee -a "$OUTPUT_FILE"
    else
        echo "$outdated_msg" | tee -a "$OUTPUT_FILE"
        echo "  $(translate "Current commit" "Commit atual" "Commit actual"): $current_commit ($current_date)" | tee -a "$OUTPUT_FILE"
        echo "  $(translate "Latest commit" "Último commit" "Último commit"): $latest_commit ($latest_date)" | tee -a "$OUTPUT_FILE"
        echo -n "$pkg_name " >> "$OUTPUT_FILE2"
    fi
}

for package in "$LIBRETRO_CORES_DIR"/*; do
    if [[ -d "$package" ]]; then
        PKG_FILE="$package/package.mk"
        PACKAGE_NAME=$(basename "$package")

        if [[ -f "$PKG_FILE" ]]; then
            PKG_SITE=$(grep "PKG_SITE=" "$PKG_FILE" | cut -d'=' -f2)
            CLEANED_PKG_SITE=$(clean_url "$PKG_SITE")
            CURRENT_VERSION=$(grep "PKG_VERSION=" "$PKG_FILE" | cut -d'=' -f2 | tr -d '"')

            if [[ -z "$CLEANED_PKG_SITE" ]]; then
                printf "$no_site_msg\n" "$PACKAGE_NAME" | tee -a "$OUTPUT_FILE"
                continue
            fi

            if [[ "$CURRENT_VERSION" =~ ^[0-9a-f]{40}$ ]]; then
                check_repo_status "$PACKAGE_NAME" "$CLEANED_PKG_SITE" "$CURRENT_VERSION"
            else
                printf "$no_git_hash_msg\n" "$PACKAGE_NAME" "$CURRENT_VERSION" | tee -a "$OUTPUT_FILE"
            fi
        else
            printf "$no_mk_file_msg\n" "$PACKAGE_NAME" | tee -a "$OUTPUT_FILE"
        fi
    fi
done

echo -n "\"" >> "$OUTPUT_FILE2"
printf "$completed_msg\n" "$OUTPUT_FILE" | tee -a "$OUTPUT_FILE"