
# Outdated Package Checker
Outdated Package Checker
This script checks and lists outdated packages in a libretro colors directory, comparing the current version with the latest version available in the corresponding Git repository.

# Description
The script is designed to check if packages inside the packages/ directory or wherever it is pointed to are out of date by comparing the current commits with the latest version available in the Git repository. It generates a list of outdated packages and creates an output file containing this information.

# Functionalities
Outdated package checker: The script checks if the packages are updated, comparing the hash of the current commit with the latest commit available in the repository.

Multiple language support: Output messages are displayed according to the language set in the system (en, pt, es).

list.txt: Contains the history of the check performed, with the date and details about each package checked (updated or outdated).

listupdate.txt: Contains a list of outdated packages, with the command to update them using the package_bump.sh script.

# Requirements
The script requires git and curl to access the repositories and get commit information.

Make sure you have jq installed to handle the JSON response from the GitHub API.

# Update outdated packages

After checking the outdated packages in listupdate.txt, you can run the corresponding command to update the packages using package_bump.sh.

Inside listupdate.txt is the command with the outdated packages for you to run, for example:

/package_bump.sh --packages "libretro-snes9x libretro-fceux"

Script based on package_bump.sh template



# Verificador de Pacotes Desatualizados
Verificador de Pacotes Desatualizados
Este script verifica e lista pacotes desatualizados em um diretório de cores libretro, comparando a versão atual com a última versão disponível no repositório Git correspondente.

# Descrição
O script foi desenvolvido para verificar se os pacotes dentro do diretório packages/ ou onde for apontado que estão desatualizados, comparando os commits atuais com a versão mais recente disponível no repositório Git. Ele gera uma lista de pacotes desatualizados e cria um arquivo de saída contendo essas informações.

# Funcionalidades
Verificação de pacotes desatualizados: O script verifica se os pacotes estão atualizados, comparando o hash do commit atual com o último commit disponível no repositório.

Suporte a múltiplos idiomas: Mensagens de saída são exibidas de acordo com a linguagem definida no sistema (en, pt, es).

list.txt: Contém o histórico da verificação realizada, com a data e os detalhes sobre cada pacote verificado (atualizado ou desatualizado).

listupdate.txt: Contém uma lista de pacotes desatualizados, com o comando pronto para atualizar usando o script package_bump.sh.

# Requisitos 
O script requer o git e curl para acessar os repositórios e obter informações de commits.

Certifique-se de ter o jq instalado para lidar com a resposta JSON da API do GitHub.

# Atualize os pacotes desatualizados

Após verificar os pacotes desatualizados no listupdate.txt, você pode executar o comando correspondente para atualizar os pacotes usando package_bump.sh.

Dentro do listupdate.txt esta o comando ja com o pacotes desatualizados para você executar por exemplo:

/package_bump.sh --packages "libretro-snes9x libretro-fceux"

Script baseado no modelo package_bump.sh

# Author
DiegroSan



