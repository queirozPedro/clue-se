from InquirerPy import inquirer
import os

class Interface:
    def __init__(self, motor_inferencia):
        self.motor_inferencia = motor_inferencia
        self.ativo = True


    def start(self):
        while self.ativo:
            opcao = self.menu_principal()
            self.executar_opcao(opcao)


    def menu_principal(self):
        opcao = inquirer.select(
            message="Escolha uma ação:",
            choices=[
                "Adicionar fato",
                "Adicionar regra",
                "Consultar base",
                "Sair"
            ],
            default=None,
            pointer="->",
            cycle=True,
        ).execute()
        return opcao


    def executar_opcao(self, opcao):
        match opcao:
            case "Adicionar fato":
                print("Adicionou fato")
            
            case "Adicionar regra":
                print("Adicionou regra")

            case "Consultar base":
                print("query")

            case "Sair":
                print("sair")
        limpar_terminal()


def limpar_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')