from InquirerPy import inquirer
from colorama import init, Fore, Style
import os
from motor.motor_inferencia import Motor_inferencia

init(autoreset=True)

class Interface:
    
    def __init__(self, motor_inferencia: Motor_inferencia):
        self.motor_inferencia = motor_inferencia
        self.ativo = True
        self.em_jogo = False
        self.quant_jogadores = 4
    

    def start(self):
        while self.ativo:
            opcao = self.menu_principal()
            self.executar_opcao(opcao)


    def menu_principal(self):
        if not self.em_jogo:
            limpar_terminal()
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
            "Exibir Cartas", # 1
            "Realizar Descarte", # 2
            "Exibir Descartadas", # 3
            "Marcar Evidencias", # 4
            "Exibir Evidencias", # 5
            "Sair"
            ],
            height=15,
            qmark="",
            default=None,
            pointer="->",
            cycle=True,
        ).execute()
        return opcao


    def executar_opcao(self, opcao):
        match opcao:
            case "Iniciar jogo com 4 jogadores":
                self.em_jogo = True
            case "Sair":
                self.ativo = False
        
        limpar_terminal()


    def executar_opcao_jogo(self, op_jogo):
        match op_jogo:
            case "Exibir Cartas": # 1
                self.exibir_cartas_jogador()
                pausar_terminal()
            
            case "Realizar Descarte": # 2
                cartas = self.motor_inferencia.obter_cartas()
                nome_cartas = [c["carta"] for c in cartas]
                opcoes = inquirer.checkbox(
                    message="Escolha as cartas que deseja descartar",
                    choices=nome_cartas,
                    height=15,
                    qmark="",
                    pointer="->",
                    cycle=True,
                ).execute()
                for op in opcoes:
                    self.motor_inferencia.descartar_carta(op)
                pausar_terminal()

            case "Exibir Descartadas": # 3
                self.exibir_descartadas_jogador()
                pausar_terminal()
            
            case "Marcar Evidencias": # 4
                cartas = self.motor_inferencia.obter_cartas()
                nome_cartas = [c["carta"] for c in cartas]
                while True:
                    evidencias = inquirer.checkbox(
                        message="Selecione suas evidências",
                        choices=nome_cartas,
                        height=15,
                        qmark="",
                        pointer="->",
                        cycle=True,
                    ).execute()
                    if len(evidencias) == 12 / self.quant_jogadores:
                        self.motor_inferencia.marcar_evidencias(evidencias)
                        pausar_terminal()
                        break
                    else:
                        print(f"Para um jogo com {self.quant_jogadores} jogadores, cada jogador deve possuir {(12 / self.quant_jogadores):.0f} evidências!")
                    pausar_terminal()
                    

            case "Exibir Evidencias": # 5
                self.exibir_evidencias_jogador()
                pausar_terminal()
                    
            case "Sair":
                print("Sair")
                self.em_jogo = False
                pausar_terminal()

        limpar_terminal()


    def exibir_cartas_jogador(self):
        cartas_jogador = self.motor_inferencia.obter_cartas()
        for cartas in cartas_jogador:
            print(f"{cartas['carta']}")
    

    def exibir_descartadas_jogador(self):
        descartadas_jogador = self.motor_inferencia.obter_descartadas()
        for descartada in descartadas_jogador:
            print(f"{descartada['carta']}")
   
   
    def exibir_evidencias_jogador(self):
        evidencias_jogador = self.motor_inferencia.obter_evidencias()
        for evidencia in evidencias_jogador:
            print(f"{evidencia['carta']}")


def limpar_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')

def pausar_terminal():
    input("")