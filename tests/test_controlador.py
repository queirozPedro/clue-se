import pytest
import os
from controlador.controlador import Controlador 

# Caminho para o arquivo Prolog
MOTOR = os.path.join(os.path.dirname(__file__), "..", "prolog", "motor_inferencia.pl")

@pytest.fixture
def controlador():
    if not os.path.exists(MOTOR):
        pytest.skip(f"Arquivo Prolog de teste não encontrado: {MOTOR}")
    ctrl = Controlador()
    return ctrl


def test_reiniciar_estado(controlador):
    controlador.reiniciar_estado()


def test_consultar_cartas_e_marcar_evidencias(controlador):
    cartas = controlador.consultar_cartas()
    assert isinstance(cartas, list)
    if cartas:
        controlador.marcar_evidencias([r["carta"] for r in cartas[:2]])


def test_atualizar_inferencias(controlador):
    controlador.atualizar_inferencias()  


def test_consultar_anotacoes_e_consultar_tipo(controlador):
    anotacoes = controlador.consultar_anotacoes()
    assert isinstance(anotacoes, list)
    for linha in anotacoes:
        if linha:
            tipo = controlador.consultar_tipo(linha[0])
            assert tipo is None or isinstance(tipo, str)


def test_tipos_diferentes(controlador):
    cartas = controlador.consultar_cartas()
    if len(cartas) >= 2:
        resultado = controlador.tipos_diferentes(cartas[0]["carta"], cartas[1]["carta"])
        assert isinstance(resultado, bool)


def test_perguntar_e_obter_perguntas(controlador):
    cartas = [r["carta"] for r in controlador.consultar_cartas()[:2]]
    jogadores = ["jogador_0", "jogador_1"]
    controlador.perguntar(cartas, jogadores, "false")
    perguntas = controlador.obter_perguntas()
    assert isinstance(perguntas, list)


def test_verificar_melhor_pergunta_e_como_perguntar(controlador):
    resultado = controlador.verificar_melhor_pergunta()
    assert isinstance(resultado, list)
    resultado2 = controlador.como_perguntar()
    assert isinstance(resultado2, list)


def test_verificar_melhor_acusacao(controlador):
    resultado = controlador.verificar_melhor_acusacao()
    assert isinstance(resultado, list)


def test_contar_cartas_jogador(controlador):
    qtd = controlador.contar_cartas_jogador("jogador_0")
    assert isinstance(qtd, int)