import os
from pyswip import Prolog

class Motor_inferencia:
    def __init__(self, ):
        self.carregar_prolog()

    def carregar_prolog(self):
        # Caminho local do arquivo
        caminho_local = os.path.join(os.path.dirname(__file__), "..", "prolog", "base_conhecimento.pl")
        # Caminho global do arquivo
        caminho_completo = os.path.abspath(caminho_local)
        
        # erro
        if not os.path.exists(caminho_completo):
            raise FileNotFoundError(f"Arquivo Prolog não encontrado: {caminho_completo}")

        self.prolog = Prolog()
        # carregar arquivo
        self.prolog.consult(caminho_completo)


    def como_perguntar(self):
        query = self.prolog.query("como_perguntar(Status, Status_perguntado, Carta)")
        for result in query:
            print(f"{result['Carta']} : {result['Status']} {result['Status_perguntado']}")
