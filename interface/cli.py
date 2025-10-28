from InquirerPy import inquirer
from colorama import init, Fore, Style
import os
from motor.motor_inferencia import Motor_inferencia
import re

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
            "Perguntar", # 6
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
                limpar_terminal()
                self.exibir_cartas_jogador()
                pausar_terminal()
            
            case "Realizar Descarte": # 2
                limpar_terminal()
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
                limpar_terminal()
                self.exibir_descartadas_jogador()
                pausar_terminal()
            
            case "Marcar Evidencias": # 4
                limpar_terminal()
                cartas = self.motor_inferencia.obter_cartas()
                nome_cartas = [c["carta"] for c in cartas]
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
                else:
                    print(f"Para um jogo com {self.quant_jogadores} jogadores, cada jogador deve possuir {(12 / self.quant_jogadores):.0f} evidências!")
                pausar_terminal()       

            case "Exibir Evidencias": # 5
                limpar_terminal()
                self.exibir_evidencias_jogador()
                pausar_terminal()
            
            case "Perguntar":
                limpar_terminal()
                op = [
                    { "name": f"Jogador_{i} para Jogador_{(i+1) % self.quant_jogadores}", "value": i }
                    for i in range(self.quant_jogadores)
                ]
                jogadores_pergunta = inquirer.select(
                    message="Selecione os jogadores da pergunta",
                    choices=op,
                    height=self.quant_jogadores,
                    qmark="",
                    default=None,
                    pointer="->",
                    cycle=True,
                ).execute()
                
                nome_cartas = [c["carta"] for c in self.motor_inferencia.obter_cartas()]
                cartas_pergunta = inquirer.checkbox(
                    message=
                    f"Selecione as cartas perguntadas",
                    choices=nome_cartas,
                    height=15,
                    qmark="",
                    pointer="->",
                    cycle=True, 
                ).execute()
                
                if len(cartas_pergunta) == 2:
                    if self.motor_inferencia.tipos_diferentes(cartas_pergunta[0], cartas_pergunta[1]):
                        if jogadores_pergunta == 0:
                            resposta_pergunta = inquirer.select(
                                message="Selecione a Resposta da sua Pergunta",
                                choices=[
                                    {"name": f"{cartas_pergunta[0]}", "value": 0},
                                    {"name": f"{cartas_pergunta[1]}", "value": 1},
                                    {"name": "Não posso ajudar", "value": 2} 
                                ],
                                height=3,
                                qmark="",
                                default=None,
                                pointer="->",
                                cycle=True,
                            ).execute()
                            self.motor_inferencia.perguntar(cartas_pergunta, ["j0", "j1"], "false" if resposta_pergunta == 2 else cartas_pergunta[resposta_pergunta])
                        else:
                            resposta_pergunta = inquirer.select(
                                message="Selecione a Resposta da Pergunta entre os Jogadores",
                                choices=[
                                    {"name": "Mostrou a Carta", "value": 0},
                                    {"name": "Não posso ajudar", "value": 1} 
                                ],
                                height=3,
                                qmark="",
                                default=None,
                                pointer="->",
                                cycle=True,
                            ).execute()
                    else:
                        print("As cartas perguntadas devem ser de tipos diferentes")
                else: 
                    print("A pergunta deve conter duas cartas de tipos diferentes")
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