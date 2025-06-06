
```
   _____  _    __  __    _           _    ____ _____ ___ ___  _   _ 
 |_   _|/ \   \ \/ /   / \         / \  / ___|_   _|_ _/ _ \| \ | |
   | | / _ \   \  /   / _ \ _____ / _ \| |     | |  | | | | |  \| |
   | |/ ___ \  /  \  / ___ \_____/ ___ \ |___  | |  | | |_| | |\  |
   |_/_/   \_\/_/\_\/_/   \_\   /_/   \_\____| |_| |___\___/|_| \_|
                                                                   
``` 
## Introdução

Taxa Action é um jogo 2D em desenvolvimento na engine Godot 4, cujo objetivo é construir um PC enquanto escapa das temidas taxas do vilão Taxad. Inspirado por desafios cotidianos, o game combina ação, estratégia e humor com uma proposta educativa e divertida.

# Objetivo

- Criar um jogo 2D com narrativa leve e gameplay envolvente.
- Aplicar princípios sólidos de desenvolvimento com Godot 4.
- Aprimorar o trabalho em equipe utilizando controle de versão com Git e metodologias ágeis.

## Arquitetura Geral

O projeto segue uma arquitetura modular baseada em componentes separados por função: controle de personagens, inimigos, mapas, HUD, sistemas de colisão e lógica de cena.

```
graph TD
  Jogo -->|Controla| Jogador
  Jogo -->|Contém| Inimigos
  Jogador -->|Possui| ScriptsPlayer
  Inimigos -->|Possuem| ScriptsEnemy
  Jogador -->|Interage| Mundo
  Mundo -->|Inclui| mapa_principal
  mapa_principal -->|Chama| CenaDeTeste

```

## Estrutura de Pastas


```
TAXA_ACTION/
├── .godot/                     # Arquivos de configuração do projeto
├── atores/
│   ├── enemy/
│   │   ├── assets/             # Sprites e sons dos inimigos
│   │   ├── scripts/
│   │   │   └── enemy.tscn      # Cena do inimigo com lógica
│   └── player/
│       ├── assets/             # Sprites e sons do jogador
│       ├── scripts/
│       │   ├── player.gd
│       │   ├── hurtbox.gd
│       │   └── player.tscn     # Cena principal do jogador
├── hitbox/                     # Elementos de colisão
├── projeteis/                  # Gerenciamento de projéteis
├── tutorial/
│   └── tutorial.tscn           # Cena de tutorial
├── worlds/
│   ├── mapa_principal/         # Mapas do jogo
│   │   └── teste.tscn          # Cena de teste do mundo
├── .editorconfig               # Configuração padrão do editor

```

## Como Rodar o Projeto

```bash
# Clone o repositório oficial
git clone https://github.com/VINYCIU51/TAXA_ACTION.git
cd TAXA_ACTION

# Abra com Godot 4
godot4 .
```

*Requisitos:*  
- Godot Engine 4.x instalada  
- Sistema operacional compatível (Windows, Linux, macOS)  

---

## Funcionalidades Atuais

- Movimento básico do personagem jogador com animações e colisão.  
- IA simples dos inimigos Taxad para perseguir o jogador.  
- Sistema de dano e vida para jogador e inimigos.  
- Mecanismo de coleta de peças para montar o PC.  
- Cenários de teste para desenvolver níveis futuros.  
- Interface HUD básica mostrando vida e peças coletadas.  
- Tela de tutorial inicial explicando controles e objetivo.  

---

 ## Integrantes do Projeto


| Nome              | Função                                   | GitHub                                   |
|-------------------|-----------------------------------------|------------------------------------------|
| Kayki Ivan        | Programação e Mecânicas                  | [xFrostzss](https://github.com/xFrostzss)   |
| Gleison Oliveira  | Game Design e Level Design                | [gleiSUN](https://github.com/gleiSUN)        |
| Kayky Rodrigues   | Design Gráfico / Arte, Animações e Efeitos Visuais | [xFrostzss](https://github.com/xFrostzss)   |
| Vinycius Huellyson| Programação                             | [VINYCIU51](https://github.com/VINYCIU51)   |
| Fernando da Silva | Áudio e Interface (UI, UX)               | [FernandosenaDev](https://github.com/FernandosenaDev) |

---

# Considerações Finais

O projeto Taxa Action está em fase inicial, focado em prototipagem rápida e desenvolvimento modular para facilitar futuras expansões. A colaboração entre os membros é essencial para manter a qualidade e aderência aos objetivos. Espera-se que a comunidade possa contribuir com melhorias e novos recursos, consolidando um jogo divertido e educativo.

Agradecemos seu interesse e contribuição!
