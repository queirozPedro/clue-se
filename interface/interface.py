from InquirerPy import inquirer
import os
from controlador.controlador import Controlador

class Interface:
    
    def __init__(self, controlador: Controlador):
        self.controlador = controlador
        self.ativo = True
        self.em_jogo = False
        self.quant_jogadores = 4
    

    def start(self):
        try:
            # Loop da interface
            while self.ativo:
                opcao = self.menu_principal()
                self.executar_opcao(opcao)
        except Exception as e:
            print(f"Erro durante a execução da interface: {e}")


    def menu_principal(self):
        '''
        Exibe o menu inicial do projeto
        '''
        try:
            limpar_terminal()
            # Opções de iniciar o jogo ou sair
            return inquirer.select(
                message="Selecione uma opção:",
                choices=["Iniciar nova sessão", "Encerrar sistema"],
                qmark="",
                pointer="->",
                cycle=True,
            ).execute()
        except Exception as e:
            print("Erro durante a execução do menu principal : {e}")


    def executar_opcao(self, opcao):
        if opcao == "Encerrar sistema":
            self.ativo = False
            return
        if opcao == "Iniciar nova sessão":
            self.iniciar_sessao_jogo()


    def iniciar_sessao_jogo(self):

        self.controlador.reiniciar_estado()
        self.coletar_evidencias()
        
        self.em_jogo = True  
        # Loop do jogo
        while self.em_jogo:
            op_jogo = self.menu_jogo()
            self.controlador.atualizar_inferencias()
            self.executar_opcao_jogo(op_jogo)


    def coletar_evidencias(self):
        while True:
            limpar_terminal()
            cartas = self.controlador.consultar_cartas()
            quantidade = int(12 / self.quant_jogadores)
            choices = [
                {
                    "name": f"{formatar_nome_carta(c['carta']):<15} ({c['tipo']})",
                    "value": c["carta"]
                }
                for c in cartas
            ]

            evidencias = inquirer.checkbox(
                message=f"Selecione exatamente {quantidade} cartas para registrar como evidências",
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
                print(f"Cada jogador deve registrar {quantidade} evidências.")

            pausar_terminal()


    def menu_jogo(self):
        limpar_terminal()
        return inquirer.select(
            message="Selecione uma opção:",
            choices=[
                "Visualizar anotações",
                "Registrar pergunta",
                "Sugestão de resposta",
                "Sugestão de acusação",
                "Sair do sistema"
            ],
            height=15,
            qmark="",
            pointer="->",
            cycle=True,
        ).execute()


    def executar_opcao_jogo(self, op_jogo):
        match op_jogo:
            case "Visualizar anotações":
                limpar_terminal()
                string = "Anotações do Jogador\n\n"
                resultado = self.controlador.consultar_anotacoes()
                for linha in resultado:
                    tipo = (
                    # Controla o espaço que deve saltar para manter a indentação 
                        f"({self.controlador.consultar_tipo(linha[0])})" +
                        " " * (0 if self.controlador.consultar_tipo(linha[0]) == "suspeito" 
                                 else 3 if self.controlador.consultar_tipo(linha[0]) == "lugar"
                                 else 4) 
                    )
                    string += f"{formatar_nome_carta(linha[0]):<14} {tipo} -> {formatar_info_carta(linha[1])}\n"
                print("".join(string))
                print("Pressione Enter para prosseguir")
                pausar_terminal()

            case "Registrar pergunta":
                limpar_terminal()

                op = [
                    { "name": f"Jogador 0 para Jogador 1", "value": 1 },
                    { "name": f"Jogador 1 para Jogador 2", "value": 2 },
                    { "name": f"Jogador 2 para Jogador 3", "value": 3 }
                ]
                jogadores_pergunta = inquirer.select(
                    message="Selecione os envolvidos na pergunta:",
                    choices=op,
                    height=self.quant_jogadores,
                    qmark="",
                    default=None,
                    pointer="->",
                    cycle=True,
                ).execute()

                if jogadores_pergunta == 1:
                    if self.controlador.contar_cartas_jogador("jogador_1") < 3:
                        # Verificando qual a melhor opção de pergunta
                        resultado = self.controlador.verificar_melhor_pergunta()
                        
                        string = "Cartas recomendadas para a pergunta:\n(Cartas agrupadas com outras do mesmo tipo possuem a mesma chance de estarem com o outro jogador)\n"
                        string += f"\nTipo: {self.controlador.consultar_tipo(resultado[0][0][0]).capitalize()}"
                        
                        for carta, info in resultado[0]:
                            string += f"\n{formatar_nome_carta(carta):<14} -> {formatar_info_carta(info)}"    
                            
                        string += f"\n\nTipo: {self.controlador.consultar_tipo(resultado[1][0][0]).capitalize()}"
                        for carta, info in resultado[1]:
                            string += f"\n{formatar_nome_carta(carta):<14} -> {formatar_info_carta(info)}"    
                        
                        print("".join(string))
                        
                        # Exibindo a lista com as cartas e seus status
                        resultado = self.controlador.como_perguntar()
                        choices = [
                            {
                                "name": 
                                f"{formatar_nome_carta(linha[1]):<15}" 
                                f"({self.controlador.consultar_tipo(linha[1])})"
                                + " " * (0 if self.controlador.consultar_tipo(linha[1]) == "suspeito" 
                                        else 3 if self.controlador.consultar_tipo(linha[1]) == "lugar"
                                        else 4)+  
                                f" -> {formatar_info_carta(linha[2])}",
                                "value": linha[1]
                            }
                            for linha in resultado
                        ]                          

                        cartas_pergunta = inquirer.checkbox(
                            message=f"\nRegistre sua pergunta",
                            choices=choices,
                            height=15,
                            qmark="",
                            pointer="->",
                            cycle=True,
                        ).execute()

                        limpar_terminal()
                        if len(cartas_pergunta) == 2:
                            if self.controlador.tipos_diferentes(cartas_pergunta[0], cartas_pergunta[1]):
                                choices = [
                                        {
                                            "name": f"{formatar_nome_carta(linha[1])}", "value": linha[1]
                                        }
                                        for linha in resultado
                                    ]        
                                resposta_pergunta = inquirer.select(
                                    message="Registre a resposta da pergunta",
                                    choices=[
                                        {"name": f"{formatar_nome_carta(cartas_pergunta[0])}", "value": 0},
                                        {"name": f"{formatar_nome_carta(cartas_pergunta[1])}", "value": 1},
                                        {"name": "Não posso ajudar", "value": 2} 
                                    ],
                                    height=3,
                                    qmark="",
                                    default=None,
                                    pointer="->",
                                    cycle=True,
                                ).execute()
                                if not self.controlador.perguntar(cartas_pergunta, ["jogador_0", "jogador_1"], "false" if resposta_pergunta == 2 else cartas_pergunta[resposta_pergunta]):
                                    print("Pergunta inválida")
                                pausar_terminal()
                            else:
                                print("As cartas selecionadas devem ser de tipos distintos")
                                pausar_terminal()
                        elif len(cartas_pergunta) > 0:
                            print("Uma pergunta deve conter exatamente duas cartas")
                            pausar_terminal()
                    else:
                        print("Não há mais cartas disponíveis para o Jogador 1")
                        pausar_terminal()
                else:

                    cartas = self.controlador.consultar_cartas()
                    choices = [
                        {
                            "name": f"{formatar_nome_carta(c['carta'])}",
                            "value": c["carta"]
                        }
                        for c in cartas
                    ]

                    cartas_pergunta = inquirer.checkbox(
                        message=f"Selecione as cartas envolvidas na pergunta",
                        choices=choices,
                        height=15,
                        qmark="",
                        pointer="->",
                        cycle=True,
                    ).execute()
                    
                    if len(cartas_pergunta) == 2:
                        if self.controlador.tipos_diferentes(cartas_pergunta[0], cartas_pergunta[1]):
                            resposta_pergunta = inquirer.select(
                                message="Selecione a resposta da pergunta:",
                                choices=[
                                    {"name": "Mostrou a Carta", "value": "true"},
                                    {"name": "Não posso ajudar", "value": "false"} 
                                ],
                                height=3,
                                qmark="",
                                default=None,
                                pointer="->",
                                cycle=True,
                            ).execute()
                            self.controlador.perguntar(cartas_pergunta, ["jogador_1", "jogador_2"] if jogadores_pergunta == 1 else ["jogador_2", "jogador_3"], resposta_pergunta)
                        else:
                            print("As cartas selecionadas devem ser de tipos distintos")
                    else: 
                        print("Uma pergunta deve conter exatamente duas cartas")
                    pausar_terminal()
            
            case "Sugestão de resposta":
                cartas = self.controlador.consultar_cartas()
                choices = [
                    {
                        "name": f"{formatar_nome_carta(c['carta']):<15} ({c['tipo']})",
                        "value": c["carta"]
                    }
                    for c in cartas
                ]

                cartas_pergunta = inquirer.checkbox(
                    message=f"Selecione as cartas envolvidas na pergunta",
                    choices=choices,
                    height=15,
                    qmark="",
                    pointer="->",
                    cycle=True,
                ).execute()
                
                if len(cartas_pergunta) == 2:
                    if self.controlador.tipos_diferentes(cartas_pergunta[0], cartas_pergunta[1]):
                        carta_resposta = self.controlador.responder_pergunta(cartas_pergunta)
                        if carta_resposta:
                            print(f"Resposta: {formatar_nome_carta(carta_resposta)}")
                        else:
                            print("Resposta: Não posso te ajudar")
                    else:
                        print("As cartas selecionadas devem ser de tipos distintos") 
                else:
                    print("Uma pergunta deve conter exatamente duas cartas")
                    
                pausar_terminal()
            
            case "Sugestão de acusação":
                limpar_terminal()
                
                resultado = self.controlador.verificar_melhor_acusacao()
                string = "Palpite de acusação baseado nas informações coletadas.\n" \
                "Cartas agrupadas com outras do mesmo tipo representam a mesma chance de estarem envolvidas no crime."
                for cartas in resultado:
                    string += f"\n\nCarta do tipo {self.controlador.consultar_tipo(cartas[0][0])}:"
                    for carta, info in cartas:
                        string += f"\n{formatar_nome_carta(carta):<14} -> {formatar_info_carta(info)}"    
                print(string)

                pausar_terminal()

            case "Sair do sistema":
                self.em_jogo = False


def formatar_nome_carta(nome):
    return (nome.capitalize()
        .replace("_", " ")
        .replace("Castical", "Castiçal")
        .replace("Revolver", "Revólver"))


def formatar_info_carta(info):
    return (info.capitalize()
        .replace("_", " ")
        .replace("nao", "não")
        .replace("Nao", "Não")
        .replace("Sem info", "Sem informação")
        .replace("evidencia", "evidencia"))


def limpar_terminal():
    os.system('cls' if os.name == 'nt' else 'clear')


def pausar_terminal():
    input("")
