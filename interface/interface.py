from InquirerPy import inquirer
from colorama import init, Fore, Style
import os
from controlador.controlador import Controlador
import re

init(autoreset=True)

class Interface:
    
    def __init__(self, controlador: Controlador):
        self.controlador = controlador
        self.ativo = True
        self.em_jogo = False
        self.quant_jogadores = 4
    

    def start(self):
        # Loop da interface
        while self.ativo:
            opcao = self.menu_principal()
            self.executar_opcao(opcao)

    def menu_principal(self):
        limpar_terminal()
        # Opções de iniciar o jogo ou sair
        return inquirer.select(
            message="Escolha uma ação:",
            choices=["Iniciar jogo", "Sair"],
            qmark="",
            pointer="->",
            cycle=True,
        ).execute()


    def executar_opcao(self, opcao):
        if opcao == "Sair":
            self.ativo = False
            return

        if opcao == "Iniciar jogo":
            self.iniciar_sessao_jogo()


    def iniciar_sessao_jogo(self):

        self.controlador.reiniciar_estado()
        pausar_terminal()
        self.coletar_evidencias()
        
        self.em_jogo = True  
        # Loop do jogo
        while self.em_jogo:
            op_jogo = self.menu_jogo()
            self.controlador.atualizar_inferencias()
            self.executar_opcao_jogo(op_jogo)



    def coletar_evidencias(self):
        """
        Docstring for coletar_evidencias
        
        :param self: Description
        """
        while True:
            limpar_terminal()
            cartas = self.controlador.obter_cartas()
            nome_cartas = [c["carta"] for c in cartas]
            quantidade = int(12 / self.quant_jogadores)
            choices = [{"name": f"{carta.capitalize().replace("_", " ").replace("Castical", "Castiçal") :<15}", "value": carta} for carta in nome_cartas]

            evidencias = inquirer.checkbox(
                message=f"Selecione as suas {quantidade} evidências ",
                choices=choices,
                height=15,
                qmark="",
                pointer="->",
                cycle=True,
            ).execute()
            
            if len(evidencias) == 12 / self.quant_jogadores:
                self.controlador.marcar_evidencias(evidencias)
                break
            else:
                print(f"Para um jogo com {self.quant_jogadores} jogadores, cada jogador deve possuir {quantidade} evidências!")
            pausar_terminal()


    def menu_jogo(self):
        limpar_terminal()
        return inquirer.select(
            message="Escolha uma ação:",
            choices=[
                "Visualizar Cartas",
                "Fazer Pergunta",
                "Registrar Perguntas",
                "Responder Pergunta",
                "Realizar Acusação",
                "Sair do Sistema"
            ],
            height=15,
            qmark="",
            pointer="->",
            cycle=True,
        ).execute()


    def executar_opcao_jogo(self, op_jogo):
        match op_jogo:
            case "Visualizar Cartas":
                limpar_terminal()
                resultado = self.controlador.visualizar_anotacoes()
                for linha in resultado:
                    nome_formatado = (
                        linha[0]
                        .capitalize()               
                        .replace("_", " ")          
                        .replace("Castical", "Castiçal") 
                    )
                    info_formatada = (
                        linha[1]
                        .capitalize()
                        .replace("Carta_evidencia", "Evidência") 
                        .replace("Carta_crime", "Crime") 
                        .replace("Sem_info", "Sem Informações") 
                    )
                    string = f"{nome_formatado:<14} -> {info_formatada}"
                    print(string)
                print("\nPressione Enter Para continuar!")
                pausar_terminal()

            case "Fazer Pergunta":
                limpar_terminal()
                resultado = self.controlador.verificar_melhor_pergunta()

                # print("Melhores opções de pergunta")

                # for carta, info in resultado:
                #     nome_formatado = (
                #         carta.capitalize().replace("_", " ").replace("Castical", "Castiçal") )
                #     info_formatada = (
                #         info.capitalize().replace("nao", "não") )
                #     string = f"{nome_formatado:<14} -> {info_formatada}"    
                #     print(string)
                
                # print("\n")
                
                # for carta, info in resultado:
                #     nome_formatado = (
                #         carta.capitalize().replace("_", " ").replace("Castical", "Castiçal") )
                #     info_formatada = (
                #         info.capitalize().replace("nao", "não") )
                #     string = f"{nome_formatado:<14} -> {info_formatada}"    
                #     print(string)
                
                # resultado = self.controlador.como_perguntar()
                # choices = [
                #     {
                #         "name": f"{linha[1].capitalize().replace('_', ' ').replace('Castical', 'Castiçal'):<15} -> {linha[2].capitalize().replace('nao', 'não')}",
                #         "value": linha[1]
                #     }
                #     for linha in resultado
                # ]                          

                # cartas_pergunta = inquirer.checkbox(
                #     message=f"Registre sua pergunta",
                #     choices=choices,
                #     height=15,
                #     qmark="",
                #     pointer="->",
                #     cycle=True,
                # ).execute()

                # limpar_terminal()
                # if len(cartas_pergunta) == 2:
                #     if self.controlador.tipos_diferentes(cartas_pergunta[0], cartas_pergunta[1]):
                #         choices = [
                #                 {
                #                     "name": f"{linha[1].capitalize().replace('_', ' ').replace('Castical', 'Castiçal'):<15}", "value": linha[1]
                #                 }
                #                 for linha in resultado
                #             ]        
                #         resposta_pergunta = inquirer.select(
                #             message="Registre a resposta da pegunta",
                #             choices=[
                #                 {"name": f"{cartas_pergunta[0].capitalize().replace('_', ' ').replace('Castical', 'Castiçal'):<15}", "value": 0},
                #                 {"name": f"{cartas_pergunta[1].capitalize().replace('_', ' ').replace('Castical', 'Castiçal'):<15}", "value": 1},
                #                 {"name": "Não posso ajudar", "value": 2} 
                #             ],
                #             height=3,
                #             qmark="",
                #             default=None,
                #             pointer="->",
                #             cycle=True,
                #         ).execute()
                #         self.controlador.perguntar(cartas_pergunta, ["j0", "j1"], "false" if resposta_pergunta == 2 else cartas_pergunta[resposta_pergunta])
                pausar_terminal()

            case "Registrar Perguntas":
                pass

            case "Responder Pergunta":
                pass

            case "Realizar Acusação":
                pass

            case "Sair do Sistema":
                self.em_jogo = False
                print("Sistema Finalizado")
                pausar_terminal()

def limpar_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')

def pausar_terminal():
    input("")
