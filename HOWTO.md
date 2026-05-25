# pptx2pdf — Guia de Uso

## Visão Geral

```
pptx2pdf [flags] entrada(s)... [diretório_de_saída]
```

Converte PowerPoint (`.pptx`) para PDF e vice-versa.

---

## Flags

### `--fresh`

Força **perfil novo do LibreOffice** a cada execução via `-env:UserInstallation`.

Útil quando footer/header aparecem distorcidos ou configurações anteriores estão corrompidas.

```bash
pptx2pdf --fresh apresentacao.pptx
pptx2pdf --fresh *.pptx --delete
```

---

### `--faithful`

Renderiza **cada slide como imagem em 300 DPI** e remonta o PDF.

**Pipeline:** `PPTX → LibreOffice → PDF → pdftoppm → PNGs → img2pdf → PDF`

Útil quando imagens mudam de tamanho ou formatação fica diferente do original.

```bash
pptx2pdf --faithful apresentacao.pptx
pptx2pdf --faithful *.pptx -d
```

**Contras:** arquivo maior, texto não selecionável, conversão mais lenta.

**Dica — instale fontes MS:**

```bash
# Arch / CachyOS
sudo pacman -S ttf-liberation ttf-croscore
# Debian / Ubuntu
sudo apt install fonts-liberation fonts-crosextra-carlito fonts-crosextra-caladea
```

---

### `-d` / `--delete`

Apaga os arquivos de entrada após conversão.

```bash
pptx2pdf *.pptx -d
pptx2pdf --faithful *.pptx -d
```

---

### `-o ARQUIVO` / `--output ARQUIVO`

Nome do arquivo de saída (apenas com **um** arquivo de entrada).

```bash
pptx2pdf apresentacao.pptx -o versao_final.pdf
pptx2pdf apresentacao.pdf -o editavel.pptx
```

---

## Modos de conversão

### PPTX → PDF

```bash
pptx2pdf slide.pptx
pptx2pdf slide.pptx ./pdfs
pptx2pdf *.pptx
pptx2pdf --faithful slide.pptx
```

### PDF → PPTX

```bash
pptx2pdf apresentacao.pdf
pptx2pdf apresentacao.pdf -o editavel.pptx
pptx2pdf --faithful apresentacao.pdf -o editavel.pptx
```

> Nota: PDF→PPTX produz slides com o conteúdo como imagem, não editável.

---

## Combinando flags

```bash
pptx2pdf --fresh *.pptx -d
pptx2pdf --faithful *.pptx -d
```

---

## Troubleshooting

### "unrecognized arguments: --fresh"
Reinstale: `./install.sh`

### Fontes diferentes / formatação estranha
Instale fontes (ver `--faithful`) ou use `--faithful`.

### LibreOffice não encontrado
`which libreoffice` — instale com seu gerenciador de pacotes.

### pdftoppm não encontrado
`sudo pacman -S poppler` (Arch) ou `sudo apt install poppler-utils` (Debian).

---

## Desinstalação

```bash
./uninstall.sh
pip3 uninstall python-pptx img2pdf -y
```
