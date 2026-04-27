# project-doc-tool

Herramienta de generacion de documentos estandarizados para proyectos de implementacion. Genera reportes de sprint y post-implementacion en formato LaTeX o Markdown, con conversion automatica a PDF.

## Tipos de documentos

**Reportes de sprint** (por cada sprint):
- **Sprint Review**: Resumen de trabajo, retrospectiva, reuniones.
- **Product Increment**: Evidencia de configuracion con IDs, tablas y criterios de aceptacion.

**Reportes post-implementacion** (cierre de proyecto):
- **Informe de Implementacion**: Requerimientos, tecnologia, sprints, resultados, plan de capacitacion (~60-70 paginas).
- **Resumen Ejecutivo**: Problema, metodologia, resultados, impactos (~7 paginas).
- **Lecciones Aprendidas**: Reflexion con tabla de 3 rondas (~5 paginas).

## Instalacion rapida

Se incluyen scripts que instalan todas las dependencias automaticamente.

**Arch Linux:**

```bash
./scripts/install_linux.sh
```

**Windows (PowerShell como Administrador):**

```powershell
.\scripts\install_windows.ps1
```

Los scripts instalan LaTeX, Pandoc, PlantUML, Java, Graphviz y UV de forma interactiva (preguntan antes de cada componente opcional).

Despues de instalar las dependencias:

```bash
git clone <url-del-repositorio>
cd project-doc-tool
uv sync
```

## Requisitos del sistema (instalacion manual)

Si prefieres instalar manualmente en lugar de usar los scripts:

### Python y UV

El proyecto usa [UV](https://docs.astral.sh/uv/) como gestor de paquetes.

**Arch Linux:**

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
```

**Windows (PowerShell):**

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

### LaTeX

Necesario para compilar archivos `.tex` a PDF.

**Arch Linux:**

```bash
sudo pacman -S texlive-basic texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-langspanish
```

**Windows:**

1. Descargar MiKTeX desde https://miktex.org/download (recomendado).
2. Ejecutar el instalador y seleccionar "Install missing packages on the fly: Yes".
3. MiKTeX descarga automaticamente los paquetes faltantes en la primera compilacion.
4. Verificar con `pdflatex --version` en CMD.

Alternativa: TeX Live desde https://tug.org/texlive/acquire-netinstall.html. Despues de instalar, agregar al PATH: `C:\texlive\2025\bin\windows` (ajustar el ano).

### Paquetes LaTeX requeridos

Todos los templates usan estos paquetes. En Arch Linux se instalan con los meta-paquetes de arriba. En Windows, MiKTeX los descarga automaticamente.

| Paquete | Proposito | Proveedor (Arch) |
|---|---|---|
| `inputenc` | Codificacion UTF-8 para caracteres especiales | texlive-basic |
| `fontenc` | Codificacion de fuentes T1 | texlive-basic |
| `babel` (spanish) | Soporte de idioma espanol (guiones, etiquetas) | texlive-langspanish |
| `geometry` | Margenes de pagina (2.5cm) | texlive-latexrecommended |
| `graphicx` | Inclusion de imagenes (`\includegraphics`) | texlive-latexrecommended |
| `hyperref` | URLs clicables y referencias cruzadas | texlive-latexrecommended |
| `longtable` | Tablas que abarcan multiples paginas | texlive-latexrecommended |
| `booktabs` | Lineas profesionales en tablas (`\toprule`, `\midrule`) | texlive-latexextra |
| `tabularx` | Tablas con columnas de ancho automatico (`X`) | texlive-latexextra |
| `enumitem` | Listas personalizadas con control de indentacion | texlive-latexextra |
| `fancyhdr` | Encabezados y pies de pagina personalizados | texlive-latexextra |
| `titlesec` | Formato de titulos de seccion con lineas de color | texlive-latexextra |
| `xcolor` | Colores personalizados para encabezados e indicadores | texlive-latexextra |
| `float` | Posicionamiento preciso de figuras/tablas (`[H]`) | texlive-latexextra |
| `caption` | Posicion de captions (arriba) y alineacion izquierda | texlive-latexextra |
| `pdflscape` | Paginas horizontales (rotadas en el visor PDF) | texlive-latexextra |
| `etoolbox` | Hooks de entorno (auto `\noindent` en tabularx) | texlive-latexextra |
| `setspace` | Control de interlineado (`\onehalfspacing`) | texlive-latexextra |
| `helvet` | Familia de fuentes Helvetica/Arial | texlive-fontsrecommended |
| `amsmath` | Formulas matematicas | texlive-latexrecommended |
| `tikz` | Diagramas vectoriales nativos de LaTeX | texlive-basic |

**Librerias TikZ usadas:** `arrows.meta`, `positioning`, `shapes.geometric`, `fit`, `backgrounds`

### Pandoc (opcional)

Solo necesario para convertir Markdown a PDF. Pandoc usa `pdflatex` como motor, por lo que LaTeX debe estar instalado.

**Arch Linux:**

```bash
sudo pacman -S pandoc
```

**Windows:**

Descargar desde https://pandoc.org/installing.html (el instalador agrega `pandoc` al PATH automaticamente).

### PlantUML (opcional)

Para generar diagramas UML (casos de uso, secuencia, modelo de datos). Requiere **Java** y **Graphviz**.

**Arch Linux:**

```bash
sudo pacman -S graphviz jdk-openjdk

mkdir -p ~/.local/lib ~/.local/bin
curl -L -o ~/.local/lib/plantuml.jar \
  "https://github.com/plantuml/plantuml/releases/download/v1.2024.7/plantuml-1.2024.7.jar"
printf '#!/bin/sh\njava -jar ~/.local/lib/plantuml.jar "$@"\n' > ~/.local/bin/plantuml
chmod +x ~/.local/bin/plantuml
export PATH="$HOME/.local/bin:$PATH"
```

**Windows:**

1. Instalar Java desde https://adoptium.net/.
2. Instalar Graphviz desde https://graphviz.org/download/ (el instalador agrega `dot` al PATH).
3. Descargar `plantuml.jar` de https://plantuml.com/download.
4. Crear un archivo `plantuml.bat` en una carpeta del PATH:
   ```bat
   @echo off
   java -jar "C:\ruta\a\plantuml.jar" %*
   ```

**Dependencia de Graphviz por tipo de diagrama:**

| Tipo de diagrama | Necesita Graphviz? |
|---|---|
| Secuencia | No |
| Actividad | No |
| Caso de Uso | Si |
| Clase / ER | Si |
| Componente | Si |

### Verificar instalacion

```bash
pdflatex --version
pandoc --version        # opcional
plantuml -version       # opcional
dot -V                  # Graphviz, opcional
```

## Uso

### Reportes de sprint

```bash
# Crear carpeta del sprint (LaTeX)
uv run python project_management/scripts/create_sprint.py 4 \
  --period "10 de Febrero, 2026 -- 21 de Febrero, 2026"

# Con consulta a Odoo + Markdown + PDF
uv run python project_management/scripts/create_sprint.py 4 \
  --period "10 de Febrero, 2026 -- 21 de Febrero, 2026" \
  --start-date 2026-02-10 --end-date 2026-02-22 \
  --format markdown --with-pdf

# Compilar PDFs
uv run python project_management/scripts/compile_sprint.py 4

# Limpiar archivos auxiliares
uv run python project_management/scripts/clean_sprint.py 4
```

### Reportes post-implementacion

```bash
# Crear reporte
uv run python project_management/scripts/create_report.py implementation --format latex
uv run python project_management/scripts/create_report.py executive_summary --format latex
uv run python project_management/scripts/create_report.py lessons_learned --format markdown

# Compilar a PDF
uv run python project_management/scripts/compile_report.py implementation
uv run python project_management/scripts/compile_report.py lessons_learned --file lessons_learned.md
```

### Consulta a Odoo (standalone)

```bash
uv run python project_management/scripts/query_odoo.py \
  --start-date 2026-01-26 --end-date 2026-02-01
```

Requiere un archivo `.env` con las credenciales de conexion a Odoo.

## Configuracion del proyecto

Editar `project_management/defaults/config.py` para personalizar:

- Nombre de empresa, RUC, representante legal
- Codigo de proyecto y programa
- Personas (coordinador, consultor, co-consultor)
- Ciudad, pais, ano
- Colores del tema LaTeX
- Imagenes (portada, logo)

Los templates usan placeholders `{{PLACEHOLDER}}` que se reemplazan con los valores de `config.py`.

## Estructura del proyecto

```
project-doc-tool/
├── pyproject.toml
├── README.md
├── scripts/
│   ├── install_linux.sh          # Instalador de dependencias para Arch Linux
│   └── install_windows.ps1       # Instalador de dependencias para Windows
└── project_management/
    ├── defaults/
    │   └── config.py               # Metadata del proyecto y empresa
    ├── docs/
    │   ├── WORKFLOW.md             # Flujo de trabajo completo
    │   ├── LATEX_SETUP.md          # Guia de instalacion detallada
    │   ├── STYLE_GUIDE.md          # Referencia de estilos LaTeX
    │   ├── REPORT_CHECKLIST.md     # Checklist de entregables
    │   └── AI_INSTRUCTIONS.md     # Instrucciones para agentes AI
    ├── helpers/
    │   ├── odoo_query.py           # Consultas XML-RPC a Odoo
    │   ├── renderer.py             # Renderizado de templates
    │   └── md_to_pdf.py            # Conversion Markdown a PDF (Pandoc)
    ├── templates/                  # Templates .tex y .md
    ├── scripts/                    # Scripts de generacion de reportes
    └── generated/                  # Directorio de salida (gitignored)
```

## Documentacion adicional

- [WORKFLOW.md](project_management/docs/WORKFLOW.md) -- Flujo paso a paso
- [LATEX_SETUP.md](project_management/docs/LATEX_SETUP.md) -- Instalacion detallada de LaTeX, Pandoc y PlantUML
- [STYLE_GUIDE.md](project_management/docs/STYLE_GUIDE.md) -- Guia de estilos LaTeX
- [REPORT_CHECKLIST.md](project_management/docs/REPORT_CHECKLIST.md) -- Checklist de entregables
