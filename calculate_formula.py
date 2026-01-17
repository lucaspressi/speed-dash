#!/usr/bin/env python3

# Dados do jogo referência
LEVEL = 64
XP_REQUIRED_64 = 666750
XP_INTO_LEVEL = 535080
SPEED_DISPLAY = 4779693
TOTAL_XP_BEFORE_64 = SPEED_DISPLAY - XP_INTO_LEVEL  # 4,244,613

def xp_mixed(level, base, scale, exp):
    return base + scale * (level ** exp)

def total_xp(level, base, scale, exp):
    return sum(xp_mixed(l, base, scale, exp) for l in range(1, level))

# Grid search
best = None
best_error = float('inf')

print("Procurando parâmetros...")

for base in range(0, 35001, 5000):
    for scale in range(100, 1001, 100):
        for exp_int in range(130, 201):
            exp = exp_int / 100.0

            xp_calc = xp_mixed(LEVEL, base, scale, exp)
            total_calc = total_xp(LEVEL, base, scale, exp)

            err_xp = abs(xp_calc - XP_REQUIRED_64) / XP_REQUIRED_64
            err_total = abs(total_calc - TOTAL_XP_BEFORE_64) / TOTAL_XP_BEFORE_64

            if err_xp < 0.005 and err_total < 0.005:
                total_err = err_xp + err_total
                if total_err < best_error:
                    best_error = total_err
                    best = (base, scale, exp, xp_calc, total_calc, err_xp, err_total)

if best:
    base, scale, exp, xp_calc, total_calc, err_xp, err_total = best
    print(f"\nMELHOR SOLUÇÃO:")
    print(f"BASE = {base}")
    print(f"SCALE = {scale}")
    print(f"EXPONENT = {exp:.4f}")
    print(f"\nXPRequired(64): {xp_calc:,.0f} (alvo: {XP_REQUIRED_64:,}) - Erro: {err_xp*100:.4f}%")
    print(f"TotalXP até 64: {total_calc:,.0f} (alvo: {TOTAL_XP_BEFORE_64:,}) - Erro: {err_total*100:.4f}%")

    print(f"\n\nCÓDIGO LUA:")
    print(f"""
ProgressionConfig.FORMULA = {{
    type = "mixed",
    BASE = {base},
    SCALE = {scale},
    EXPONENT = {exp},
}}
""")

    print("\nTABELA DE PROGRESSÃO:")
    print(f"{'Level':<8} {'XPRequired':>15} {'TotalXP':>20}")
    print("-" * 50)
    for lvl in [1, 5, 10, 20, 30, 40, 50, 60, 64, 70, 80, 90, 100]:
        xp_req = xp_mixed(lvl, base, scale, exp)
        total = total_xp(lvl, base, scale, exp)
        marker = " ⭐" if lvl == 64 else ""
        print(f"{lvl:<8} {xp_req:>15,.0f} {total:>20,.0f}{marker}")
else:
    print("Nenhuma solução encontrada com erro < 0.5%")
