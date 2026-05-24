# pptx2pdf

Converte arquivos PowerPoint (`.pptx`) para PDF e vice-versa usando o **LibreOffice** em modo headless. Preserva formatação, imagens, fontes e layouts originais.

## Instalação

### Linux

```bash
chmod +x install.sh && ./install.sh
```

O script instala o LibreOffice (via apt/dnf/pacman/zypper) e adiciona o comando ao PATH.

### Windows

```powershell
.\install.ps1
```

O script abre a página de download do LibreOffice caso não esteja instalado e adiciona o comando ao PATH do usuário.

## Uso

```bash
# PPTX → PDF
pptx2pdf apresentacao.pptx
pptx2pdf apresentacao.pptx ~/Documentos
pptx2pdf *.pptx ./pdfs

# PDF → PPTX
pptx2pdf apresentacao.pdf

# Apagar originais após conversão
pptx2pdf *.pptx ./pdfs --delete
pptx2pdf apresentacao.pptx -d

# Nome customizado (apenas um arquivo)
pptx2pdf apresentacao.pptx -o resultado.pdf
```

## Requisitos

- **Python 3**
- **LibreOffice** (instalado automaticamente no Linux pelo `install.sh`)

## Estrutura

```
pptx2pdf/
├── pptx2pdf.py       # Script principal
├── install.sh        # Instalador Linux
├── install.ps1       # Instalador Windows
├── uninstall.sh      # Desinstalador Linux
└── README.md
```
