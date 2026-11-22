\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{OTHRartcl}[2025/10/20 v0.02-dev OTH Regensburg Article Class]

\DeclareOption{department=FakEI}{}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{scrartcl}}
\ProcessOptions\relax

\LoadClass{scrartcl}

\RequirePackage{graphicx}
\RequirePackage{iftex}

\ifTUTeX
    \RequirePackage{fontspec}
    \setmainfont{DejaVu Serif}[Scale=0.91]
    \setsansfont{DejaVu Sans}[Scale=0.91]
    \setmonofont{DejaVu Sans Mono}[Scale=0.91]
    \renewcommand{\familydefault}{\sfdefault}
\else
    \RequirePackage[T1]{fontenc}
    \RequirePackage[scaled=0.91]{DejaVuSans}
    \RequirePackage[scaled=0.91]{DejaVuSansMono}
    \renewcommand{\familydefault}{\sfdefault}
\fi

\newcommand{\TheLogo}{%
    \includegraphics[width=267.83517pt]{othr-logo_flat.pdf}%
}
