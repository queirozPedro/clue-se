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


    def obter_cartas(self):
        try:
            resultados = [
                {"carta": r["Carta"], "tipo": r["Tipo"]}
                for r in self.prolog.query("carta(Carta, Tipo)")
            ]
            return resultados
        except Exception as e:
            print(f"Erro ao consultar cartas: {e}")
            return []
    

    def obter_descartadas(self):
        try:
            resultados = [
                {"carta": r["Carta"], "tipo": r["Tipo"]}
                for r in self.prolog.query("descartada(Carta, Tipo)")
            ]
            return resultados
        except Exception as e:
            print(f"Erro ao consultar descartadas: {e}")
            return []
        

    def descartar_carta(self, carta):
        list(self.prolog.query(f"descartar_carta({carta})"))
    

    def marcar_evidencias(self, cartas):
        self.prolog.retractall("(evidencia(_, _))")
        
        for carta in cartas:
            resultados = list(self.prolog.query(f"carta({carta}, Tipo)"))
            for r in resultados:
                tipo = r['Tipo']
                self.prolog.assertz(f"evidencia({carta}, {tipo})")

    
    def obter_evidencias(self):
        try:
            resultados = [
                {"carta": r["Carta"], "tipo": r["Tipo"]}
                for r in self.prolog.query("evidencia(Carta, Tipo)")
            ]
            return resultados
        except Exception as e:
            print(f"Erro ao consultar evidencia: {e}")
            return []


    def tipos_diferentes(self ,carta_a, carta_b):
        try:
            resultado = list(self.prolog.query(f"tipos_diferentes({carta_a}, {carta_b})"))
            if resultado:
                return True
            else:
                return False
        except Exception as e:
            print(f"Erro ao consultar tipos_diferentes: {e}")
            return False



    def como_perguntar(self):
        query = self.prolog.query("como_perguntar(Status, Status_perguntado, Carta)")
        for result in query:
            print(f"{result['Carta']} : {result['Status']} {result['Status_perguntado']}")

