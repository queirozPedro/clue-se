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


    def consultar_cartas(self):
        try:
            resultados = [
                {"carta": r["Carta"], "tipo": r["Tipo"]}
                for r in self.prolog.query("carta(Carta, Tipo)")
            ]
            return resultados
        except Exception as e:
            print(f"Erro ao consultar cartas: {e}")
            return []


    def consultar_anotacoes(self):
        try:
            resultado = list(self.prolog.query("consultar_anotacoes(Resultado)."))

            # resultado é uma lista com uma única posição contendo um dicionário
            cartas = resultado[0]["Resultado"]

            text = []
            for r in cartas:
                string = (
                    r.replace(",(", " ")
                    .replace("b'", " ")
                    .replace("')", " ")
                    .split(",")
                )
                string = [t.strip() for t in string]
                text.append(string)
            return text

        except Exception as e:
            print(f"Erro em consultar_anotacoes: {e}")
            return []


    def marcar_evidencias(self, cartas):
        try:
            for carta in cartas:
                next(self.prolog.query(f"marcar_evidencia({carta})"))
        except Exception as e:
            print(f"Erro ao marcar_evidencias: {e}")
  

    def verificar_melhor_pergunta(self):
        try:
            resultado = list(self.prolog.query("melhor_pergunta(Resultado)."))

            text = []
            for r in resultado[0]["Resultado"]:
                s = (r.replace(",(", " ")
                    .replace("b'", " ")
                    .replace("[", " ")
                    .replace("]", " ")
                    .replace('"', " ")
                    .replace(")", " ")
                    .replace("'", " "))

                partes = [t.strip() for t in s.split(",") if t.strip()]
                pares = [(partes[i], partes[i+1]) for i in range(0, len(partes), 2)]
                text.append(pares)
            return text

        except Exception as e:
            print(f"Erro ao verificar melhor pergunta: {e}")
            return []
        
    
    def como_perguntar(self):
        try:
            resultado = list(self.prolog.query("como_perguntar(Resultado)."))
            # resultado é uma lista com uma posição, que é um dicionário que só tem uma chave "Resultado", que dá para uma lista de strings
            text = []
            for r in resultado[0]["Resultado"]:
                string = r.replace(",(", " ").replace("b'", " ").replace("'))", " ").split(",")
                string = [t.strip() for t in string]
                text.append(string)
            return text

        except Exception as e:
            print(f"Erro ao executar como_perguntar: {e}")
            return []
        
    
    def perguntar(self, cartas, jogadores, resposta):
        try:
            return list(self.prolog.query(
                f"registrar_pergunta({jogadores[0]}, {jogadores[1]}, {cartas[0]}, {cartas[1]}, {resposta})"
            ))
        except Exception as e:
            print(f"Erro ao registrar pergunta: {e}")
            return False

    
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
        
    def consultar_tipo(self, carta):
        try:
            resultado = list(self.prolog.query(f"carta({carta}, Tipo)"))
            return resultado[0]["Tipo"]
        except Exception as e:
            print(f"Erro ao consultar tipo da carta {carta}: {e}")
            return None


    def responder_pergunta(self, cartas):
        resultado = list(self.prolog.query(f"como_responder({cartas[0]}, {cartas[1]}, Info)"))
        string = f"{resultado[0]["Info"]}"
        
        if "carta_a" in string:
            return cartas[0]
        elif "carta_b" in string:
            return cartas[1]
        else:
            return False
        
    def verificar_melhor_acusacao(self):
        try:
            resultado = list(self.prolog.query("melhor_acusacao(Resultado)."))

            text = []
            for r in resultado[0]["Resultado"]:
                s = (
                    r.replace(",(", " ")
                    .replace("b'", " ")
                    .replace("[", " ")
                    .replace("]", " ")
                    .replace('"', " ")
                    .replace(")", " ")
                    .replace("'", " ")
                )

                partes = [t.strip() for t in s.split(",") if t.strip()]
                pares = [(partes[i], partes[i+1]) for i in range(0, len(partes), 2)]
                text.append(pares)
            return text

        except Exception as e:
            print(f"Erro ao verificar melhor acusacao: {e}")
            return []


    def contar_cartas_jogador(self, jogador):
        try:
            resultado = list(self.prolog.query(f"tem_carta({jogador}, _)"))
            return len(resultado)
        except Exception as e:
            print(f"Erro ao contar cartas do jogador {jogador}: {e}")
            return 0


    def atualizar_inferencias(self):
        try:
            list(self.prolog.query("executar_inferencias"))
        except Exception as e:
            print(f"Erro ao atualizar inferências: {e}")


    def reiniciar_estado(self):
        try:
            list(self.prolog.query("reiniciar_estado"))
        except Exception as e:
            print(f"Erro ao reiniciar estado: {e}")