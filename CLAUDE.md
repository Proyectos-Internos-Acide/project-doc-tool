# project-doc-tool

Herramienta de generacion de documentos estandarizados (LaTeX/Markdown a PDF) para proyectos de implementacion de ERP bajo el programa ProInnovate del gobierno peruano.

## Estructura del proyecto

```
src/
├── defaults/config.py          # Metadata de empresa, proyecto, personas, colores
├── docs/
│   ├── AI_INSTRUCTIONS.md      # Instrucciones detalladas para agentes de IA
│   ├── STYLE_GUIDE.md          # Formato LaTeX completo (preambulo, tablas, indentacion)
│   ├── REPORT_CHECKLIST.md     # Lista de inputs necesarios antes de generar un informe
│   ├── WORKFLOW.md             # Flujo paso a paso para sprints y reportes
│   └── LATEX_SETUP.md          # Instalacion de LaTeX, Pandoc, PlantUML
├── examples/                   # PDFs de referencia reales (fuente de verdad del formato)
│   ├── RESULTS_REPORT/         # Informes de implementacion R1-R3 (~60-70 paginas cada uno)
│   ├── EXECUTIVE_SUMMARY/      # Resumen ejecutivo (~7 paginas)
│   ├── LEARNED_LESSONS/        # Lecciones aprendidas (~5 paginas)
│   └── INDEXED_PHOTOS/         # Formato de fotos indexadas
├── helpers/
│   ├── renderer.py             # Renderizado de templates con placeholders {{VAR}}
│   ├── odoo_query.py           # Consultas XML-RPC a Odoo por rango de fechas
│   └── md_to_pdf.py            # Conversion Markdown a PDF via Pandoc
├── templates/                  # Templates .tex.template y .md.template
├── scripts/                    # Scripts ejecutables (create, compile, clean)
└── generated/                  # Directorio de salida (gitignored)
```

## Antes de generar contenido

Lee estos archivos en este orden:

1. `src/defaults/config.py` — Datos de empresa, proyecto, personas, colores
2. `src/docs/STYLE_GUIDE.md` — Formato LaTeX completo (preambulo, reglas criticas)
3. `src/docs/REPORT_CHECKLIST.md` — Que inputs se necesitan
4. La plantilla correspondiente en `src/templates/`
5. El archivo generado en `src/generated/` (si existe) — buscar secciones `% TODO`

Los PDFs en `src/examples/` son la referencia de como debe verse el documento final. Consultarlos cuando haya dudas de formato, nivel de detalle o tono.

## Reglas de formato LaTeX

- Acentos LaTeX: `\'a`, `\'e`, `\'i`, `\'o`, `\'u`, `\~n`
- Caption y label van ARRIBA de `\includegraphics` en figuras
- Dejar linea en blanco antes de `\begin{tabularx}` (evita renderizado inline)
- NO agregar `[leftmargin=...]` a listas individuales (el preambulo lo maneja globalmente)
- Usar `\textbf{}` para enfasis, evitar `\texttt{}` en columnas estrechas (no hyphenate)
- Helvetica es ~15-20% mas ancha que Computer Modern — revisar anchos de columna
- `\tabcolsep` es 3pt (no el default de 6pt)
- Tablas anchas: usar `\begin{landscape}...\end{landscape}` con `\linewidth`

## Tono de redaccion

- Formal, tercera persona, tiempo pasado ("se implemento", "se configuro")
- Parrafos de 3-5 oraciones
- Cada seccion abre con un parrafo introductorio que: conecta con la seccion anterior, explica el "por que", y describe la situacion antes de la implementacion
- Listas, tablas y datos tecnicos se mantienen concisos — solo la prosa recibe tratamiento narrativo
- No inventar datos — si no hay informacion, dejar `% TODO` especifico
- Ver `src/docs/AI_INSTRUCTIONS.md` > "Tono y estilo de redaccion" para ejemplos completos

## Diagramas PlantUML

Encabezado estandar para todos los diagramas:

```plantuml
@startuml
!theme plain
skinparam backgroundColor white
skinparam defaultFontName Arial
skinparam defaultFontSize 11
skinparam shadowing false
skinparam roundCorner 8
```

Generar PNGs con: `plantuml -tpng diagrams/*.puml -o "$(pwd)/img/"`

El flag `-o` requiere ruta absoluta. Usar `$(pwd)` para construirla.

## Compilacion

```bash
# Compilacion basica (1 pasada)
pdflatex -interaction=nonstopmode archivo.tex

# Con TOC/LOF/LOT (2 pasadas)
pdflatex -interaction=nonstopmode archivo.tex
pdflatex -interaction=nonstopmode archivo.tex

# Verificar overflows (0-3 cosmeticos es aceptable)
grep "Overfull" archivo.log
```

## Comandos del proyecto

```bash
# Sprints
uv run python src/scripts/create_sprint.py N --period "FECHA"
uv run python src/scripts/compile_sprint.py N
uv run python src/scripts/clean_sprint.py N

# Reportes post-implementacion (implementation | executive_summary | lessons_learned)
uv run python src/scripts/create_report.py TIPO --format latex
uv run python src/scripts/compile_report.py TIPO

# Consulta standalone a Odoo
uv run python src/scripts/query_odoo.py --start-date YYYY-MM-DD --end-date YYYY-MM-DD
```

## Errores comunes

- `tabularx` sin linea en blanco antes: overflow de 92-133pt (renderiza inline)
- `booktabs` rules extienden ~17pt mas alla del ancho de tabularx: cosmetico, aceptado
- `\texttt{}` en columnas `p{Ncm}` estrechas: no hyphenate, usar texto plano
- `\list` resetea `\leftskip`: las listas usan `\listlabelindent` via enumitem (no parchear manualmente)
- Landscape pages: usar `\thispagestyle{empty}` + header/footer manual (fancyhdr no rota bien)
