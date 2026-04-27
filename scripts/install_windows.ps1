# Installation script for project-doc-tool dependencies on Windows
# Run in PowerShell as Administrator (for winget/choco) or as normal user (for UV)

$ErrorActionPreference = "Stop"

Write-Host "=== project-doc-tool: Windows dependency installer ===" -ForegroundColor Cyan
Write-Host ""

# -------------------------------------------------------------------------
# Detect package manager
# -------------------------------------------------------------------------
$useWinget = $false
$useChoco = $false

if (Get-Command winget -ErrorAction SilentlyContinue) {
    $useWinget = $true
    Write-Host "  Package manager: winget" -ForegroundColor Green
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    $useChoco = $true
    Write-Host "  Package manager: chocolatey" -ForegroundColor Green
} else {
    Write-Host "  No package manager found (winget or chocolatey)." -ForegroundColor Yellow
    Write-Host "  You will need to install dependencies manually." -ForegroundColor Yellow
}
Write-Host ""

# -------------------------------------------------------------------------
# 1. LaTeX (MiKTeX)
# -------------------------------------------------------------------------
Write-Host "[1/4] LaTeX (MiKTeX)" -ForegroundColor Cyan

if (Get-Command pdflatex -ErrorAction SilentlyContinue) {
    Write-Host "  pdflatex already installed: $(pdflatex --version 2>&1 | Select-Object -First 1)"
} else {
    Write-Host "  MiKTeX provides all required LaTeX packages:"
    Write-Host "    inputenc, fontenc, babel, geometry, graphicx, booktabs, tabularx,"
    Write-Host "    enumitem, hyperref, xcolor, fancyhdr, titlesec, longtable, float,"
    Write-Host "    amsmath, tikz, helvet, setspace, etoolbox, caption, pdflscape"
    Write-Host ""

    if ($useWinget) {
        Write-Host "  Installing MiKTeX via winget..."
        winget install MiKTeX.MiKTeX --accept-package-agreements --accept-source-agreements
    } elseif ($useChoco) {
        Write-Host "  Installing MiKTeX via chocolatey..."
        choco install miktex -y
    } else {
        Write-Host "  Please install MiKTeX manually:" -ForegroundColor Yellow
        Write-Host "    1. Download from https://miktex.org/download"
        Write-Host "    2. Run installer, select 'Install missing packages on the fly: Yes'"
    }
    Write-Host ""
    Write-Host "  IMPORTANT: MiKTeX auto-installs missing LaTeX packages on first use."
    Write-Host "  On first compilation, click 'Install' when prompted for missing packages."
}
Write-Host ""

# -------------------------------------------------------------------------
# 2. Pandoc (optional)
# -------------------------------------------------------------------------
Write-Host "[2/4] Pandoc (optional - for Markdown to PDF)" -ForegroundColor Cyan

if (Get-Command pandoc -ErrorAction SilentlyContinue) {
    Write-Host "  pandoc already installed: $(pandoc --version | Select-Object -First 1)"
} else {
    $installPandoc = Read-Host "  Install Pandoc? [Y/n]"
    if ($installPandoc -eq "" -or $installPandoc -match "^[Yy]$") {
        if ($useWinget) {
            winget install JohnMacFarlane.Pandoc --accept-package-agreements --accept-source-agreements
        } elseif ($useChoco) {
            choco install pandoc -y
        } else {
            Write-Host "  Download from https://pandoc.org/installing.html" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  Skipping Pandoc."
    }
}
Write-Host ""

# -------------------------------------------------------------------------
# 3. PlantUML + Java + Graphviz (optional)
# -------------------------------------------------------------------------
Write-Host "[3/4] PlantUML + Java + Graphviz (optional - for UML diagrams)" -ForegroundColor Cyan

$installPlantUML = Read-Host "  Install PlantUML and dependencies? [Y/n]"
if ($installPlantUML -eq "" -or $installPlantUML -match "^[Yy]$") {

    # Java
    if (Get-Command java -ErrorAction SilentlyContinue) {
        Write-Host "  Java already installed."
    } else {
        Write-Host "  Installing Java (Adoptium Temurin)..."
        if ($useWinget) {
            winget install EclipseAdoptium.Temurin.21.JDK --accept-package-agreements --accept-source-agreements
        } elseif ($useChoco) {
            choco install temurin21 -y
        } else {
            Write-Host "  Download Java from https://adoptium.net/" -ForegroundColor Yellow
        }
    }

    # Graphviz
    if (Get-Command dot -ErrorAction SilentlyContinue) {
        Write-Host "  Graphviz already installed."
    } else {
        Write-Host "  Installing Graphviz..."
        if ($useWinget) {
            winget install Graphviz.Graphviz --accept-package-agreements --accept-source-agreements
        } elseif ($useChoco) {
            choco install graphviz -y
        } else {
            Write-Host "  Download from https://graphviz.org/download/" -ForegroundColor Yellow
        }
    }

    # PlantUML jar
    $plantUMLDir = "$env:LOCALAPPDATA\PlantUML"
    $plantUMLJar = "$plantUMLDir\plantuml.jar"
    $plantUMLBat = "$plantUMLDir\plantuml.bat"
    $plantUMLVersion = "1.2024.7"

    if (!(Test-Path $plantUMLDir)) {
        New-Item -ItemType Directory -Path $plantUMLDir -Force | Out-Null
    }

    if (Test-Path $plantUMLJar) {
        Write-Host "  PlantUML jar already exists at $plantUMLJar"
    } else {
        Write-Host "  Downloading PlantUML v${plantUMLVersion}..."
        $url = "https://github.com/plantuml/plantuml/releases/download/v${plantUMLVersion}/plantuml-${plantUMLVersion}.jar"
        Invoke-WebRequest -Uri $url -OutFile $plantUMLJar
    }

    # Create batch wrapper
    Set-Content -Path $plantUMLBat -Value "@echo off`njava -jar `"$plantUMLJar`" %*"
    Write-Host "  PlantUML installed at $plantUMLBat"

    # Add to PATH if not already there
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$plantUMLDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$plantUMLDir", "User")
        Write-Host "  Added $plantUMLDir to user PATH (restart terminal to take effect)."
    }

} else {
    Write-Host "  Skipping PlantUML."
}
Write-Host ""

# -------------------------------------------------------------------------
# 4. UV (Python package manager)
# -------------------------------------------------------------------------
Write-Host "[4/4] UV (Python package manager)" -ForegroundColor Cyan

if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "  UV already installed: $(uv --version)"
} else {
    $installUV = Read-Host "  Install UV? [Y/n]"
    if ($installUV -eq "" -or $installUV -match "^[Yy]$") {
        Write-Host "  Installing UV..."
        powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    } else {
        Write-Host "  Skipping UV."
    }
}
Write-Host ""

# -------------------------------------------------------------------------
# Verify
# -------------------------------------------------------------------------
Write-Host "=== Verification ===" -ForegroundColor Cyan
$tools = @(
    @{Name="pdflatex"; Cmd="pdflatex --version 2>&1 | Select-Object -First 1"},
    @{Name="pandoc"; Cmd="pandoc --version | Select-Object -First 1"},
    @{Name="plantuml"; Cmd="plantuml -version 2>&1 | Select-Object -First 1"},
    @{Name="dot"; Cmd="dot -V 2>&1"},
    @{Name="uv"; Cmd="uv --version"}
)

foreach ($tool in $tools) {
    try {
        $result = Invoke-Expression $tool.Cmd 2>$null
        Write-Host "  $($tool.Name): $result" -ForegroundColor Green
    } catch {
        Write-Host "  $($tool.Name): not found" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=== Done! Run 'uv sync' in the project directory to set up Python. ===" -ForegroundColor Cyan
