import os
from pyswip import Prolog

class Controlador:
    def __init__(self, ):
        self.carregar_prolog()


    def carregar_prolog(self):
        # Caminho local do arquivo
        caminho_local = os.path.join(os.path.dirname(__file__), "..", "prolog", "motor_inferencia.pl")
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


    def visualizar_anotacoes(self):
        resultado = list(self.prolog.query("visualizar_cartas(Resultado)."))
        # resultado é uma lista com uma posição, que é um dicionário que só tem uma chave "Resultado", que dá para uma lista de strings
        text = []
        for r in resultado[0]["Resultado"]:
            string = r.replace(",(", " ").replace("b'", " ").replace("')", " ").split(",")
            string = [t.strip() for t in string]
            text.append(string)
        return text
        

    def marcar_evidencias(self, cartas):
        for carta in cartas:
            next(self.prolog.query(f"marcar_evidencia({carta})"))
            

    def verificar_melhor_pergunta(self):
        resultado = list(self.prolog.query("melhor_pergunta(Resultado)."))

        text = []
        for r in resultado[0]["Resultado"]:
            s = (r.replace(",(", " ")
                .replace("b'", " ")
                .replace("[", " ")
                .replace("]", " ")
                .replace('"', " ")
                .replace(")", " "))

            partes = [t.strip() for t in s.split(",") if t.strip()]
            pares = [(partes[i], partes[i+1]) for i in range(0, len(partes), 2)]
            text.append(pares)
        return text
        
    
    def como_perguntar(self):
        resultado = list(self.prolog.query("como_perguntar(Resultado)."))
        # resultado é uma lista com uma posição, que é um dicionário que só tem uma chave "Resultado", que dá para uma lista de strings
        text = []
        for r in resultado[0]["Resultado"]:
            string = r.replace(",(", " ").replace("b'", " ").replace("'))", " ").split(",")
            string = [t.strip() for t in string]
            text.append(string)
        return text
        
    
    def perguntar(self, cartas, jogadores, resposta):
        list(self.prolog.query(f"registrar_pergunta({jogadores[0]}, {jogadores[1]}, {cartas[0]}, {cartas[1]}, {resposta})"))
    
    def obter_perguntas(self):
        try:
            resultados = [
                {"jogador_a": r["Jogador_a"], "jogador_b": r["Jogador_b"], "carta_a": r["Carta_a"], "carta_b": r["Carta_b"], "resposta": r["Resposta"]}
                for r in self.prolog.query(f"perguntar(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta)")
            ]
            return resultados
        except Exception as e:
            print(f"Erro ao buscar perguntas: {e}")
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
        

    def atualizar_inferencias(self):
        print("executar_inferencias()")
        list(self.prolog.query("executar_inferencias"))


    def reiniciar_estado(self):
        list(self.prolog.query("reiniciar_estado"))