## Clue Suspeitos - Sistema Especialista em Prolog

Este projeto implementa um Sistema Especialista (SE) com motor de inferência lógica utilizando a linguagem Prolog, aplicado ao jogo Clue Suspeitos®. O objetivo do sistema é simular o raciocínio dedutivo necessário para identificar o autor do crime, o local e a arma, por meio de uma base de conhecimento estruturada e regras lógicas.

O SE permite ao usuário interagir com o sistema para registrar evidências, formular perguntas e obter sugestões de respostas ou acusações, automatizando a análise das informações ocultas e suportando decisões estratégicas no jogo. O projeto combina a lógica declarativa do Prolog com a modelagem das regras do jogo, oferecendo uma ferramenta educativa e experimental para explorar inferências automatizadas em contextos de jogos de raciocínio lógico.

---

## Instalação
### Pré-requisitos

- Python 3.10 ou superior
- SWI-Prolog

### Passo a Passo de Instalação

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
* No Windows:
```bash
venv\Scripts\activate
```

* No macOS / Linux:
```bash
source venv/bin/activate
```

4. **Instalar as dependências**

```bash
pip install -r requirements.txt
```

5. **Verificar a instalação do SWI-Prolog**

```bash
swipl --version
```

6. **Executar o sistema**

```bash
python main.py
```

