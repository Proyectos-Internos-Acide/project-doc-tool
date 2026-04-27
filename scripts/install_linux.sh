#!/usr/bin/env bash
# Installation script for project-doc-tool dependencies on Arch Linux
set -euo pipefail

echo "=== project-doc-tool: Linux (Arch) dependency installer ==="
echo ""

# -------------------------------------------------------------------------
# 1. LaTeX (TeX Live)
# -------------------------------------------------------------------------
echo "[1/4] Installing LaTeX (TeX Live) packages..."
sudo pacman -S --needed --noconfirm \
    texlive-basic \
    texlive-latexrecommended \
    texlive-latexextra \
    texlive-fontsrecommended \
    texlive-langspanish

echo ""
echo "  LaTeX packages provided:"
echo "    texlive-basic            -> pdflatex compiler"
echo "    texlive-latexrecommended -> graphicx, hyperref, geometry, longtable"
echo "    texlive-latexextra       -> booktabs, tabularx, enumitem, fancyhdr,"
echo "                                titlesec, xcolor, float, caption, pdflscape,"
echo "                                etoolbox, setspace, helvet, tikz, amsmath"
echo "    texlive-fontsrecommended -> Standard PDF fonts"
echo "    texlive-langspanish      -> babel Spanish language support"
echo ""

# -------------------------------------------------------------------------
# 2. Pandoc (optional, for Markdown -> PDF)
# -------------------------------------------------------------------------
read -rp "[2/4] Install Pandoc? (for Markdown to PDF conversion) [Y/n]: " INSTALL_PANDOC
INSTALL_PANDOC="${INSTALL_PANDOC:-Y}"
if [[ "$INSTALL_PANDOC" =~ ^[Yy]$ ]]; then
    sudo pacman -S --needed --noconfirm pandoc
    echo "  Pandoc installed."
else
    echo "  Skipping Pandoc."
fi
echo ""

# -------------------------------------------------------------------------
# 3. PlantUML + dependencies (optional, for UML diagrams)
# -------------------------------------------------------------------------
read -rp "[3/4] Install PlantUML? (for UML diagrams) [Y/n]: " INSTALL_PLANTUML
INSTALL_PLANTUML="${INSTALL_PLANTUML:-Y}"
if [[ "$INSTALL_PLANTUML" =~ ^[Yy]$ ]]; then
    echo "  Installing Java and Graphviz..."
    sudo pacman -S --needed --noconfirm graphviz jdk-openjdk

    PLANTUML_VERSION="1.2024.7"
    PLANTUML_JAR="$HOME/.local/lib/plantuml.jar"
    PLANTUML_BIN="$HOME/.local/bin/plantuml"

    mkdir -p "$HOME/.local/lib" "$HOME/.local/bin"

    if [[ -f "$PLANTUML_JAR" ]]; then
        echo "  PlantUML jar already exists at $PLANTUML_JAR"
    else
        echo "  Downloading PlantUML v${PLANTUML_VERSION}..."
        curl -L -o "$PLANTUML_JAR" \
            "https://github.com/plantuml/plantuml/releases/download/v${PLANTUML_VERSION}/plantuml-${PLANTUML_VERSION}.jar"
    fi

    printf '#!/bin/sh\njava -jar "%s" "$@"\n' "$PLANTUML_JAR" > "$PLANTUML_BIN"
    chmod +x "$PLANTUML_BIN"

    echo "  PlantUML installed at $PLANTUML_BIN"
    echo ""
    echo "  Make sure ~/.local/bin is in your PATH. Add to ~/.bashrc or ~/.zshrc:"
    echo '    export PATH="$HOME/.local/bin:$PATH"'
else
    echo "  Skipping PlantUML."
fi
echo ""

# -------------------------------------------------------------------------
# 4. UV (Python package manager)
# -------------------------------------------------------------------------
if command -v uv &>/dev/null; then
    echo "[4/4] UV is already installed: $(uv --version)"
else
    read -rp "[4/4] Install UV? (Python package manager) [Y/n]: " INSTALL_UV
    INSTALL_UV="${INSTALL_UV:-Y}"
    if [[ "$INSTALL_UV" =~ ^[Yy]$ ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        echo '  Add to your shell profile: export PATH="$HOME/.local/bin:$PATH"'
    else
        echo "  Skipping UV."
    fi
fi
echo ""

# -------------------------------------------------------------------------
# Verify installations
# -------------------------------------------------------------------------
echo "=== Verification ==="
echo -n "  pdflatex: " && (pdflatex --version 2>/dev/null | head -1 || echo "NOT FOUND")
echo -n "  pandoc:   " && (pandoc --version 2>/dev/null | head -1 || echo "not installed (optional)")
echo -n "  plantuml: " && (plantuml -version 2>/dev/null | head -1 || echo "not installed (optional)")
echo -n "  dot:      " && (dot -V 2>&1 | head -1 || echo "not installed (optional)")
echo -n "  uv:       " && (uv --version 2>/dev/null || echo "NOT FOUND")
echo ""
echo "=== Done! Run 'uv sync' in the project directory to set up Python. ==="
