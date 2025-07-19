
import os
from pyswip import Prolog

class Base_conhecimento:
        
    def __init__(self, nome_arquivo):
        self.carregar_base_conhecimento(nome_arquivo)


    def carregar_base_conhecimento(self, nome_arquivo: str):
        # Caminho local do arquivo
        base_path = os.path.join(os.path.dirname(__file__), "..", "prolog", nome_arquivo)
        # Caminho global do arquivo
        full_path = os.path.abspath(base_path)
        
        # erro
        if not os.path.exists(full_path):
            raise FileNotFoundError(f"Arquivo Prolog não encontrado: {full_path}")

        prolog = Prolog()
        # carregar arquivo
        prolog.consult(full_path)
        return prolog
