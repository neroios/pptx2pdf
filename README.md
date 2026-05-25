# pptx2pdf

Converte PowerPoint (`.pptx`) ←→ PDF usando **LibreOffice** headless.

## Instalação

### Linux

```bash
chmod +x install.sh && ./install.sh
```

Instala LibreOffice, `poppler-utils`, fontes MS-compatíveis e dependências Python.

### Windows

```powershell
.\install.ps1
```

## Flags

| Flag | Descrição |
|------|-----------|
| `--fresh` | Usa perfil novo do LibreOffice (corrige footer/header) |
| `--faithful` | Renderiza slides como imagens (300 DPI). PDF pixel-idêntico ao LibreOffice. Arquivo maior, texto não selecionável |
| `-d` / `--delete` | Apaga os originais após conversão |
| `-o ARQUIVO` / `--output ARQUIVO` | Nome de saída (apenas com 1 entrada) |

## Exemplos

```bash
pptx2pdf apresentacao.pptx
pptx2pdf *.pptx ~/Documentos
pptx2pdf --fresh apresentacao.pptx
pptx2pdf --faithful *.pptx
pptx2pdf *.pptx --delete
pptx2pdf apresentacao.pdf
pptx2pdf apresentacao.pptx -o resultado.pdf
```

## Requisitos

- **Python 3.8+**
- **LibreOffice**
- **poppler-utils** / `pdftoppm` (para `--faithful`)
- Dependências Python: `python-pptx`, `img2pdf`, `pillow`

## Estrutura

```
pptx2pdf/
├── pptx2pdf.py       # Script principal
├── install.sh        # Instalador Linux
├── install.ps1       # Instalador Windows
├── uninstall.sh      # Desinstalador Linux
├── HOWTO.md          # Guia de uso detalhado
└── README.md
```
