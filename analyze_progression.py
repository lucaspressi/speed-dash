#!/usr/bin/env python3
"""
Análise matemática completa da progressão do Speed Dash
Objetivo: Encontrar fórmula que satisfaça AMBOS os constraints
"""

import numpy as np
from scipy.optimize import minimize, curve_fit
import math

# ==================== DADOS DO JOGO REFERÊNCIA ====================
LEVEL = 64
XP_REQUIRED_64 = 666750  # XP para passar de 64 → 65
XP_INTO_LEVEL = 535080   # XP dentro do nível 64
SPEED_DISPLAY = 4779693  # Display no jogo

# Interpretação: Speed Display = TotalXP acumulado (incluindo XP parcial do nível atual)
TOTAL_XP_AT_64 = SPEED_DISPLAY  # 4,779,693
TOTAL_XP_BEFORE_64 = TOTAL_XP_AT_64 - XP_INTO_LEVEL  # 4,244,613

print("=" * 80)
print("ANÁLISE DE PROGRESSÃO - SPEED DASH")
print("=" * 80)
print(f"\nDados do Jogo Referência (Level {LEVEL}):")
print(f"  Speed Display: {SPEED_DISPLAY:,}")
print(f"  XP na Barra: {XP_INTO_LEVEL:,} / {XP_REQUIRED_64:,} ({XP_INTO_LEVEL/XP_REQUIRED_64*100:.2f}%)")
print(f"  XPRequired(64): {XP_REQUIRED_64:,}")
print(f"\nInterpretação:")
print(f"  TotalXP até Level 64 (sem XP parcial): {TOTAL_XP_BEFORE_64:,}")
print(f"  TotalXP completo (com XP parcial): {TOTAL_XP_AT_64:,}")

# ==================== TESTE 1: FÓRMULA POWER LAW PURA ====================
print("\n" + "=" * 80)
print("TESTE 1: Fórmula Power Law Pura - A * level^B")
print("=" * 80)

def xp_required_powerlaw(level, A, B):
    """XPRequired(level) = A * level^B"""
    return A * (level ** B)

def total_xp_powerlaw(level, A, B):
    """TotalXP acumulado até o nível (soma de todos XPRequired de 1 até level-1)"""
    return sum(xp_required_powerlaw(l, A, B) for l in range(1, level))

# Tentativa 1: Otimizar para XPRequired(64) = 666,750
print("\n[Tentativa 1] Otimizar apenas para XPRequired(64):")
def error_xp_only(params):
    A, B = params
    xp_calc = xp_required_powerlaw(LEVEL, A, B)
    return (xp_calc - XP_REQUIRED_64) ** 2

result = minimize(error_xp_only, x0=[1387, 1.47], bounds=[(100, 10000), (1.0, 3.0)])
A1, B1 = result.x
xp_calc_1 = xp_required_powerlaw(LEVEL, A1, B1)
total_xp_1 = total_xp_powerlaw(LEVEL, A1, B1)

print(f"  Parâmetros: A={A1:.2f}, B={B1:.4f}")
print(f"  XPRequired(64): {xp_calc_1:,.0f} (alvo: {XP_REQUIRED_64:,}) - Erro: {abs(xp_calc_1 - XP_REQUIRED_64)/XP_REQUIRED_64*100:.2f}%")
print(f"  TotalXP até 64: {total_xp_1:,.0f} (alvo: {TOTAL_XP_BEFORE_64:,}) - Erro: {abs(total_xp_1 - TOTAL_XP_BEFORE_64)/TOTAL_XP_BEFORE_64*100:.2f}%")
print(f"  ❌ TotalXP está MUITO ERRADO!")

# Tentativa 2: Otimizar para AMBOS os constraints
print("\n[Tentativa 2] Otimizar para XPRequired(64) E TotalXP:")
def error_both(params):
    A, B = params
    xp_calc = xp_required_powerlaw(LEVEL, A, B)
    total_xp_calc = total_xp_powerlaw(LEVEL, A, B)

    error_xp = ((xp_calc - XP_REQUIRED_64) / XP_REQUIRED_64) ** 2
    error_total = ((total_xp_calc - TOTAL_XP_BEFORE_64) / TOTAL_XP_BEFORE_64) ** 2

    return error_xp + error_total

result = minimize(error_both, x0=[1000, 1.5], bounds=[(100, 10000), (1.0, 3.0)])
A2, B2 = result.x
xp_calc_2 = xp_required_powerlaw(LEVEL, A2, B2)
total_xp_2 = total_xp_powerlaw(LEVEL, A2, B2)

print(f"  Parâmetros: A={A2:.2f}, B={B2:.4f}")
print(f"  XPRequired(64): {xp_calc_2:,.0f} (alvo: {XP_REQUIRED_64:,}) - Erro: {abs(xp_calc_2 - XP_REQUIRED_64)/XP_REQUIRED_64*100:.2f}%")
print(f"  TotalXP até 64: {total_xp_2:,.0f} (alvo: {TOTAL_XP_BEFORE_64:,}) - Erro: {abs(total_xp_2 - TOTAL_XP_BEFORE_64)/TOTAL_XP_BEFORE_64*100:.2f}%")
print(f"  ❌ Impossível satisfazer ambos com power law pura!")

# ==================== TESTE 2: FÓRMULA MISTA (BASE + SCALE * level^EXPONENT) ====================
print("\n" + "=" * 80)
print("TESTE 2: Fórmula Mista - BASE + SCALE * level^EXPONENT")
print("=" * 80)

def xp_required_mixed(level, BASE, SCALE, EXPONENT):
    """XPRequired(level) = BASE + SCALE * level^EXPONENT"""
    return BASE + SCALE * (level ** EXPONENT)

def total_xp_mixed(level, BASE, SCALE, EXPONENT):
    """TotalXP acumulado até o nível"""
    return sum(xp_required_mixed(l, BASE, SCALE, EXPONENT) for l in range(1, level))

def error_mixed(params):
    BASE, SCALE, EXPONENT = params
    xp_calc = xp_required_mixed(LEVEL, BASE, SCALE, EXPONENT)
    total_xp_calc = total_xp_mixed(LEVEL, BASE, SCALE, EXPONENT)

    error_xp = ((xp_calc - XP_REQUIRED_64) / XP_REQUIRED_64) ** 2
    error_total = ((total_xp_calc - TOTAL_XP_BEFORE_64) / TOTAL_XP_BEFORE_64) ** 2

    return error_xp + error_total

result = minimize(error_mixed, x0=[1000, 500, 1.5], bounds=[(0, 50000), (10, 5000), (1.0, 3.0)])
BASE, SCALE, EXPONENT = result.x
xp_calc_mixed = xp_required_mixed(LEVEL, BASE, SCALE, EXPONENT)
total_xp_mixed = total_xp_mixed(LEVEL, BASE, SCALE, EXPONENT)

print(f"\nParâmetros: BASE={BASE:.2f}, SCALE={SCALE:.2f}, EXPONENT={EXPONENT:.4f}")
print(f"XPRequired(64): {xp_calc_mixed:,.0f} (alvo: {XP_REQUIRED_64:,}) - Erro: {abs(xp_calc_mixed - XP_REQUIRED_64)/XP_REQUIRED_64*100:.4f}%")
print(f"TotalXP até 64: {total_xp_mixed:,.0f} (alvo: {TOTAL_XP_BEFORE_64:,}) - Erro: {abs(total_xp_mixed - TOTAL_XP_BEFORE_64)/TOTAL_XP_BEFORE_64*100:.4f}%")

if abs(xp_calc_mixed - XP_REQUIRED_64)/XP_REQUIRED_64*100 < 0.5 and abs(total_xp_mixed - TOTAL_XP_BEFORE_64)/TOTAL_XP_BEFORE_64*100 < 0.5:
    print("✅ SUCESSO! Fórmula mista satisfaz ambos os constraints!")
else:
    print("⚠️ Erros ainda altos, mas melhor que power law pura")

# ==================== TESTE 3: INTERPRETAÇÃO ALTERNATIVA ====================
print("\n" + "=" * 80)
print("TESTE 3: Interpretação Alternativa - Speed Display = Level * Multiplicador")
print("=" * 80)

# Hipótese: Speed Display não é TotalXP, mas sim uma função do level
multiplier = SPEED_DISPLAY / LEVEL
print(f"\nSe Speed Display = Level * Multiplicador:")
print(f"  Multiplicador = {multiplier:.2f}")
print(f"  Não faz sentido - valor muito alto ({multiplier:,.0f})")
print("  ❌ Interpretação descartada")

# ==================== TESTE 4: REGRESSÃO INVERSA ====================
print("\n" + "=" * 80)
print("TESTE 4: Engenharia Reversa - Reconstruir curva completa")
print("=" * 80)

# Se temos apenas 1 anchor, precisamos assumir uma forma de fórmula
# Vamos tentar reconstruir a curva assumindo que a progressão segue um padrão comum

# Padrão comum em jogos idle: início lento, meio rápido, fim muito rápido
# Isso sugere EXPONENT > 1.5

print("\n[Teste] Varredura de parâmetros para fórmula mista:")
best_error = float('inf')
best_params = None

for base in [0, 1000, 5000, 10000, 20000]:
    for scale in [100, 250, 500, 750, 1000]:
        for exp in np.arange(1.3, 2.0, 0.05):
            xp_calc = xp_required_mixed(LEVEL, base, scale, exp)
            total_calc = total_xp_mixed(LEVEL, base, scale, exp)

            error_xp = abs(xp_calc - XP_REQUIRED_64) / XP_REQUIRED_64
            error_total = abs(total_calc - TOTAL_XP_BEFORE_64) / TOTAL_XP_BEFORE_64

            # Ambos os erros devem ser < 0.5%
            if error_xp < 0.005 and error_total < 0.005:
                total_error = error_xp + error_total
                if total_error < best_error:
                    best_error = total_error
                    best_params = (base, scale, exp, xp_calc, total_calc, error_xp, error_total)

if best_params:
    base, scale, exp, xp_calc, total_calc, err_xp, err_total = best_params
    print(f"\n✅ MELHOR COMBINAÇÃO ENCONTRADA:")
    print(f"  BASE={base:.0f}, SCALE={scale:.0f}, EXPONENT={exp:.4f}")
    print(f"  XPRequired(64): {xp_calc:,.0f} (alvo: {XP_REQUIRED_64:,}) - Erro: {err_xp*100:.4f}%")
    print(f"  TotalXP até 64: {total_calc:,.0f} (alvo: {TOTAL_XP_BEFORE_64:,}) - Erro: {err_total*100:.4f}%")
else:
    print("\n⚠️ Nenhuma combinação perfeita encontrada com grid search")
    print("Usando melhor aproximação da otimização anterior")

# ==================== VALIDAÇÃO FINAL ====================
print("\n" + "=" * 80)
print("VALIDAÇÃO FINAL - Fórmula Recomendada")
print("=" * 80)

# Usar a melhor fórmula encontrada
if best_params:
    FINAL_BASE, FINAL_SCALE, FINAL_EXPONENT = best_params[0], best_params[1], best_params[2]
else:
    FINAL_BASE, FINAL_SCALE, FINAL_EXPONENT = BASE, SCALE, EXPONENT

print(f"\nFórmula Recomendada:")
print(f"  XPRequired(level) = {FINAL_BASE:.0f} + {FINAL_SCALE:.2f} * level^{FINAL_EXPONENT:.4f}")
print(f"\nValidação em múltiplos níveis:")

test_levels = [1, 5, 10, 20, 30, 40, 50, 60, 64, 70, 80, 90, 100]
print(f"\n{'Level':<8} {'XPRequired':>15} {'TotalXP':>15} {'Speed Display':>15}")
print("-" * 60)

for lvl in test_levels:
    xp_req = xp_required_mixed(lvl, FINAL_BASE, FINAL_SCALE, FINAL_EXPONENT)
    total = total_xp_mixed(lvl, FINAL_BASE, FINAL_SCALE, FINAL_EXPONENT)
    print(f"{lvl:<8} {xp_req:>15,.0f} {total:>15,.0f} {total:>15,.0f}")

# ==================== CÓDIGO PRONTO PARA LUA ====================
print("\n" + "=" * 80)
print("CÓDIGO PRONTO PARA COPY/PASTE (Lua)")
print("=" * 80)

lua_code = f"""
-- Fórmula calibrada: XPRequired(level) = BASE + SCALE * level^EXPONENT
-- Tipo: mixed (power law com offset)

ProgressionConfig.FORMULA = {{
    type = "mixed",               -- Tipo: mixed (BASE + SCALE * level^EXPONENT)
    BASE = {FINAL_BASE:.0f},      -- Offset constante
    SCALE = {FINAL_SCALE:.2f},    -- Coeficiente de escala
    EXPONENT = {FINAL_EXPONENT:.4f}, -- Expoente da curva
}}
"""

print(lua_code)

print("\n" + "=" * 80)
print("ANÁLISE CONCLUÍDA")
print("=" * 80)
