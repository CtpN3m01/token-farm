# Simple DeFi Token Farm

Pequeña **Farm de staking**: los usuarios depositan un token LP ("LP Token") y ganan recompensas en el token de la plataforma **DAPP** ("DApp Token").  
Incluye funciones para **depositar**, **retirar todo el LP**, **recalcular/actualizar recompensas** y **reclamarlas**. También hay un método para el **owner** que actualiza recompensas de todos los stakers periódicamente.

> 🌟 **Inspirado en PancakeSwap Farms**: Un sistema de yield farming simplificado para aprender desarrollo DeFi.

---

## ¿Para qué sirve?

- Simular un **yield farming** básico (depositas LP → generas DAPP → reclamas).
- Practicar **Solidity**, **Hardhat** y pruebas/deploy locales.
- Base para extender con *features* (comisiones, rango de recompensa por bloque, etc.).
- **Aprender conceptos DeFi**: staking, distribución de recompensas, ownership patterns.

---

## 🏗️ Arquitectura del Proyecto

### Contratos Principales

1. **`LPToken.sol`**: Token ERC20 que simula un token de liquidez (LP)
   - Minteable por el owner
   - Usado para hacer staking en la farm

2. **`DAppToken.sol`**: Token ERC20 de la plataforma usado como recompensa
   - Minteable por el owner (TokenFarm)
   - Se genera automáticamente como recompensa

3. **`TokenFarm.sol`**: Contrato principal de la farm
   - Gestiona el staking de LP tokens
   - Calcula y distribuye recompensas proporcionales
   - Sistema de comisiones configurable
   - Funciones de administración para el owner
---

## 🎯 Características Implementadas

- ✅ **Staking proporcional**: Las recompensas se distribuyen según el % de participación
- ✅ **Checkpoint system**: Calcula recompensas basado en bloques transcurridos
- ✅ **Sistema de comisiones**: Configurable en basis points (0-100%)
- ✅ **Rangos de recompensa**: Min/max recompensas por bloque configurables
- ✅ **Gestión automática**: Recalcula recompensas antes de cambios de balance
- ✅ **Eventos completos**: Para tracking y análisis
- ✅ **Seguridad**: Validaciones y uso de OpenZeppelin

---Token Farm

Pequeña **Farm de staking**: los usuarios depositan un token LP (“LP Token”) y ganan recompensas en el token de la plataforma **DAPP** (“DApp Token”).  
Incluye funciones para **depositar**, **retirar todo el LP**, **recalcular/actualizar recompensas** y **reclamarlas**. También hay un método para el **owner** que actualiza recompensas de todos los stakers periódicamente.

---

## ¿Para qué sirve?

- Simular un **yield farming** básico (depositas LP → generas DAPP → reclamas).
- Practicar **Solidity**, **Hardhat** y pruebas/deploy locales.
- Base para extender con *features* (comisiones, rango de recompensa por bloque, etc.).

---

## Requisitos

- Node.js (recomendado **v22+**)
- npm o yarn
- Git (para clonar el repositorio)

---

## 🚀 Instalación y Setup

```bash
# Clonar el repositorio
git clone https://github.com/CtpN3m01/token-farm.git
cd token-farm

# Instalar dependencias
npm install

# Compilar contratos
npx hardhat compile
```

### Dependencias Principales

- **Hardhat**: Framework de desarrollo Ethereum
- **Hardhat Toolbox + Viem**: Herramientas modernas para testing y deployment  
- **OpenZeppelin Contracts**: Librería de contratos seguros y auditados
- **Solidity 0.8.28**: Versión del lenguaje utilizada

---

## 📋 Deployment

### Red Local (Hardhat)

```bash
# Compilar contratos
npx hardhat compile

# Desplegar en red local
npx hardhat run scripts/deploy.js --network localhost

# Resultado esperado:
# 🎉 DEPLOYMENT COMPLETE!
# ==================================================
# 📊 Contract Addresses:
# DApp Token : 0x5fbdb2315678afecb367f032d93f642f64180aa3
# LP Token   : 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512  
# Token Farm : 0x9fe46736679d2d9a65f0992f2272de9f3c7fa6e0
# ==================================================
```

---

## 📚 API Reference

### TokenFarm - Funciones de Usuario

- **`deposit(uint256 _amount)`**: Deposita LP tokens para staking
  - Requiere aprobación previa del LP token
  - Actualiza recompensas automáticamente
  
- **`withdraw()`**: Retira TODOS los LP tokens del usuario
  - Actualiza recompensas antes del retiro
  - No afecta recompensas pendientes
  
- **`claimRewards()`**: Reclama recompensas DAPP acumuladas
  - Aplica comisión si está configurada
  - Resetea recompensas pendientes

### TokenFarm - Funciones de Owner

- **`setRewardRange(uint256 _min, uint256 _max)`**: Configura rango de recompensas por bloque
- **`setRewardPerBlock(uint256 _value)`**: Establece recompensa actual por bloque
- **`setCommissionRate(uint16 _bps)`**: Configura comisión (basis points: 100 = 1%)
- **`withdrawCommission(address _to)`**: Retira comisiones acumuladas
- **`distributeRewardsAll()`**: Actualiza recompensas de todos los stakers activos

### Configuración por Defecto

```solidity
minRewardPerBlock = 1e18;    // 1 DAPP por bloque
maxRewardPerBlock = 1e18;    // 1 DAPP por bloque  
rewardPerBlock = 1e18;       // 1 DAPP por bloque
commissionRate = 0;          // Sin comisión
```

---

## 🔧 Comandos Útiles

```bash
# Desarrollo
npx hardhat compile           # Compilar contratos
npx hardhat clean            # Limpiar artifacts
npx hardhat console          # Consola interactiva
npx hardhat node             # Nodo local persistente

# Información
npx hardhat accounts         # Ver cuentas disponibles
npx hardhat --help           # Ver todos los comandos
```

---

## 📁 Estructura del Proyecto

```
token-farm/
├── contracts/
│   ├── DAppToken.sol       # Token de recompensas (DAPP)
│   ├── LPToken.sol         # Token LP para staking
│   └── TokenFarm.sol       # Contrato principal de la farm
├── scripts/
│   └── deploy.js           # Script de deployment
├── hardhat.config.ts       # Configuración de Hardhat
├── package.json            # Dependencias del proyecto
├── tsconfig.json           # Configuración TypeScript
└── README.md               # Este archivo
```

---

## 🔐 Consideraciones de Seguridad

- **OpenZeppelin**: Uso de contratos base auditados y seguros
- **Reentrancy**: Protección mediante actualización de estado antes de transferencias
- **Integer Overflow**: Protección nativa de Solidity 0.8+
- **Access Control**: Modificadores `onlyOwner` y `onlyStaker`
- **Validaciones**: Verificación de inputs en todas las funciones públicas

---

## 📖 Referencias

- [PancakeSwap Farms Documentation](https://docs.pancakeswap.finance/products/yield-farming/how-to-use-farms)
- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solidity Documentation](https://docs.soliditylang.org/)

---
