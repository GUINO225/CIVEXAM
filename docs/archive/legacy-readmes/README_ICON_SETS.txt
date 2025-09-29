CivExam — Propositions d'icônes SVG (couleurs assorties)

Dossiers
- assets/icons/sets/amber/   (#FF7A00 / stroke blanc)
- assets/icons/sets/teal/    (#2EC4B6 / stroke #0B6B63)
- assets/icons/sets/cyan/    (#7BD3EA / stroke #0E7490)
- assets/icons/sets/grape/   (#7B61FF / stroke #ECEBFF)
- assets/icons/sets/lime/    (#A3E635 / stroke #1F3B00)
- assets/icons/sets/white/   (#FFFFFF / stroke #37478F)
- assets/icons/mono/         (fill='currentColor' pour recoloriser au runtime)

Palette CivExam
- Bleu profond : #0D1E42
- Bleu royal   : #37478F
- Orange accent: #FF7A00

Utilisation sets colorés (exemple) :
  'assets/icons/sets/teal/play.svg'

Utilisation mono recolorisable :
  SvgPicture.asset('assets/icons/mono/play.svg',
    width: 68, height: 68,
    colorFilter: const ColorFilter.mode(Color(0xFF2EC4B6), BlendMode.srcIn),
  );
