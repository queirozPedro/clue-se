from InquirerPy import inquirer
import os

class Interface:
    def __init__(self, motor_inferencia):
        self.motor_inferencia = motor_inferencia
        self.ativo = True
        self.em_jogo = False


    def start(self):
        while self.ativo:
            opcao = self.menu_principal()
            self.executar_opcao(opcao)


    def menu_principal(self):
        if not self.em_jogo:
            opcao = inquirer.select(
                message="Escolha uma ação:",
                choices=[
                    "Iniciar jogo com 4 jogadores",
                    "Sair"
                ],
                default=None,
                qmark="",
                pointer="->",
                cycle=True,
            ).execute()
            return opcao
        else:
            while(self.em_jogo):
                op_jogo = self.menu_jogo()
                self.executar_opcao_jogo(op_jogo)       


    def menu_jogo(self):
        opcao = inquirer.select(
            message="Escolha uma ação:",
            choices=[
            "Perguntar",
            "Como Perguntar",
            "Escutar Pergunta",
            "Descartar com ou",
            "Mostrar Cartas",
            "Mostrar Cartas Descartadas",
            "Chutar",
            "Como Chutar",
            "Sair"
            ],
            height=9,
            qmark="",
            default=None,
            pointer="->",
            cycle=True,
        ).execute()
        return opcao


    def executar_opcao(self, opcao):
        match opcao:
            case "Iniciar jogo com 4 jogadores":
                print("Iniciando Jogo")
                self.em_jogo = True
                pausar_terminal()
            case "Sair":
                self.ativo = False
        
        limpar_terminal()


    def executar_opcao_jogo(self, op_jogo):
        match op_jogo:
            case "Perguntar":
                print("Perguntar")
                pausar_terminal()
            case "Como Perguntar":
                print("Como Perguntar")
                pausar_terminal()
            case "Escutar Pergunta":
                print("Escutar Pergunta")
                pausar_terminal()
            case "Descartar com ou":
                print("Descartar com ou")
                pausar_terminal()
            case "Mostrar Cartas":
                print("Mostrar Cartas")
                pausar_terminal()
            case "Mostrar Cartas Descartadas":
                print("Mostrar Cartas Descartadas")
                pausar_terminal()
            case "Chutar":
                print("Chutar")
                pausar_terminal()
            case "Como Chutar":
                print("Como Chutar")
                pausar_terminal()
            case "Sair":
                print("Sair")
                self.em_jogo = False
                pausar_terminal()

        limpar_terminal()


def limpar_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')


def pausar_terminal():
    input("")