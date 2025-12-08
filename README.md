## Clue Suspeitos - Sistema Especialista

### Descrição

Esse projeto visa o desenvolvimento de um Sistema Especialista com Motor de Inferências em Prolog para jogar o jogo Clue Suspeitos. O sistema foi desenvolvido em Python (interface CLI) e Prolog (motor de inferência e base de conhecimento). A integração entre as partes ocorreu por meio da biblioteca pyswip, responsável por conectar o Python ao SWI-Prolog (uma implementação moderna da linguagem Prolog).

#### Sobre o Clue Suspeitos

Clue Suspeitos é um jogo do gênero detetive, no qual o jogador compete com até outros três jogadores a fim de descobrir o cenário de um crime, composto por uma arma, um lugar e um suspeito. No jogo, existem quatro armas, cinco lugares e seis suspeitos, que são representados a partir de um conjunto de cartas. No início de cada partida, uma carta de cada tipo é selecionada de maneira oculta e aleatória, sendo disposta no centro da mesa, representando o crime. As demais cartas são reunidas, embaralhadas e distribuídas igualmente entre os jogadores, definindo as evidências de cada um. Ao longo das rodadas, os jogadores devem realizar perguntas a fim de descobrir as evidências dos demais, identificando assim, por eliminação, quais cartas compõem o crime.

#### Sistema Especialista (SE)

O sistema especialista foi desenvolvido considerando o aspacto lógico e dedutivo do jogo, que representa uma estrutura adequada para a aplicação desse tipo de sistema. O Motor de Inferências, peça central de um SE, foi desenvolvido em Prolog, linguagem de programação lógica que trabalha com fatos e regras do tipo SE-ENTÃO. Cenários de jogo, lógica dedutiva aplicada a perguntas e respostas, e aquisição de conhecimento indireto foram alguns dos fatos observados durante o desenvolvimento do motor.

### Instalação do Projeto

#### Pré-requisitos

- Python 3.10 ou superior
- <a href="https://www.swi-prolog.org/">SWI-Prolog</a>

#### Passo a Passo de Instalação

1. **Clonar o repositório**

```bash
git clone https://github.com/queirozPedro/clue-se
cd clue-se
```

2. **Criar um ambiente virtual**

```bash
python -m venv venv
```

3. **Ativar um ambiente virtual**
* Windows:
```bash
venv\Scripts\activate
```
* macOS / Linux:
```bash
source venv/bin/activate
```

4. **Instalar as dependências**

```bash
pip install -r requirements.txt
```

5. **Executar o sistema**

```bash
python main.py
```

#### Sobre a utilização

O sistema usa uma interface CLI baseada em menus interativos, onde o usuário seleciona as opções usando as setas e confirma com Enter. Múltiplas seleções podem ser feitas com a barra de espaço.