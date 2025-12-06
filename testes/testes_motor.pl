:- use_module('../prolog/motor_inferencia.pl', [

    % Cartas
    carta/2,
    carta_eliminada/2,
    carta_evidencia/2,
    eliminar_carta/1,
    marcar_evidencia/1,
    carta_crime/2,
    eh_tipo/2,
    tipos_diferentes/2,
    status_carta/2,
    consultar_anotacoes/1,

    % Jogadores e Perguntas
    pergunta/5,
    tem_carta/2,
    nao_tem_carta/2,
    pode_ter_carta/3,
    registrar_pergunta/5,
    foi_perguntada/2,

    % Inferências 
    inferir_posse_cartas/0,
    inferir_carta_crime/0,
    executar_inferencias/0,

    % Perguntar  Responder  Acusar
    como_perguntar/1,
    melhor_pergunta/1,
    avaliar_carta_pergunta/3,
    prioridade_resposta/2,
    como_responder/3,
    melhor_acusacao/1,
    como_acusar/1,
    avaliar_carta_acusacao/3,

    % Auxiliar
    reiniciar_estado/0
]).

:- begin_tests(motor_inferencia_tests).

% Cada teste reinicia o estado para evitar poluição entre testes
test(eliminar_e_marcar, [setup(reiniciar_estado)]) :-
    % eliminar carta cria fato carta_eliminada/2
    eliminar_carta(faca),
    carta_eliminada(faca, arma),
    % marcar evidencia cria fato carta_evidencia/2
    marcar_evidencia(white),
    carta_evidencia(white, suspeito).

test(tipos_diferentes, [setup(reiniciar_estado)]) :-
    % testa cartas de tipos diferentes
    tipos_diferentes(faca, cozinha).

test(registrar_pergunta_resposta_a, [setup(reiniciar_estado)]) :-
    % resposta foi Carta_a
    registrar_pergunta(jogador_x, jogador_y, faca, spa, faca),
    pergunta(jogador_x, jogador_y, faca, spa, faca),
    tem_carta(jogador_y, faca),
    carta_eliminada(faca, arma).

test(registrar_pergunta_resposta_b, [setup(reiniciar_estado)]) :-
    % resposta foi Carta_b
    registrar_pergunta(jogador_x, jogador_y, faca, spa, spa),
    pergunta(jogador_x, jogador_y, faca, spa, spa),
    tem_carta(jogador_y, spa),
    carta_eliminada(spa, lugar).

test(registrar_pergunta_resposta_true, [setup(reiniciar_estado)]) :-
    % resposta true -> pode_ter_carta
    registrar_pergunta(jogador_a, jogador_b, corda, hall, true),
    pergunta(jogador_a, jogador_b, corda, hall, true),
    pode_ter_carta(jogador_b, corda, hall).

test(registrar_pergunta_resposta_false, [setup(reiniciar_estado)]) :-
    % resposta false -> nao_tem_carta para ambas
    registrar_pergunta(j1, j2, revolver, cozinha, false),
    pergunta(j1, j2, revolver, cozinha, false),
    nao_tem_carta(j2, revolver),
    nao_tem_carta(j2, cozinha).

test(foi_perguntada_predicado, [setup(reiniciar_estado)]) :-
    % verifica se a carta foi perguntada
    registrar_pergunta(a, b, faca, spa, faca),
    once(foi_perguntada(b, faca)).

test(inferir_posse_cartas_cadeia, [setup(reiniciar_estado)]) :-
    % jogador_1 tem faca e jogador_2 pode ter faca ou spa, logo jogador_2 deve ter spa
    assertz(tem_carta(jogador_1, faca)),
    assertz(pode_ter_carta(jogador_2, faca, spa)),
    inferir_posse_cartas,
    tem_carta(jogador_2, spa),
    carta_eliminada(spa, lugar).

test(inferir_carta_crime, [setup(reiniciar_estado)]) :-
    % eliminar todas as armas exceto uma, essa deve virar carta_crime
    eliminar_carta(castical),
    eliminar_carta(corda),
    eliminar_carta(revolver),
    inferir_carta_crime,
    carta_crime(faca, arma).

test(executar_inferencias_combinadas, [setup(reiniciar_estado)]) :-
    % combina inferir_posse_cartas e inferir_carta_crime via executar_inferencias/0
    assertz(tem_carta(jogador_a, corda)),
    assertz(pode_ter_carta(jogador_b, corda, cozinha)),
    eliminar_carta(sala_de_estar),
    eliminar_carta(sala_de_jantar),
    eliminar_carta(spa),
    once(executar_inferencias),
    tem_carta(jogador_b, cozinha),
    carta_crime(hall, lugar).

test(consultar_anotacoes_status, [setup(reiniciar_estado)]) :-
    % marcar alguns status e verificar consultar_anotacoes/1
    eliminar_carta(faca),
    marcar_evidencia(peacock),
    assertz(carta_crime(hall, lugar)),
    consultar_anotacoes(Lista),
    once(member((faca, "carta_eliminada"), Lista)),
    once(member((peacock, "carta_evidencia"), Lista)),
    once(member((hall, "carta_crime"), Lista)).

test(como_responder_casos, [setup(reiniciar_estado)]) :-
    % não posso te ajudar
    como_responder(faca, cozinha, R1),
    R1 == "nao posso te ajudar",
    % se só tiver faca, responda ela
    marcar_evidencia(faca),
    como_responder(faca, cozinha, R2),
    R2 == "carta_a",
    % se só tiver cozinha, responda ela
    reiniciar_estado,
    marcar_evidencia(cozinha),
    como_responder(faca, cozinha, R3),
    R3 == "carta_b",
    % marcar ambas -> prioridade por tipo (suspeito > lugar > arma)
    reiniciar_estado,
    marcar_evidencia(peacock),
    marcar_evidencia(spa),
    como_responder(peacock, spa, R4),
    R4 == "carta_a".

test(como_perguntar_melhor, [setup(reiniciar_estado)]) :-
    % preparar cenário: cartas de tipos diferentes disponíveis
    assertz(nao_tem_carta(jogador_2, revolver)),
    assertz(nao_tem_carta(jogador_3, revolver)),
    assertz(nao_tem_carta(jogador_2, scarlet)),
    % verificar que como_perguntar retorna entrada com prioridade 1
    como_perguntar(Lista),
    once(member(1-(revolver, "nao possuida pelos jogadores 2 e 3"), Lista)),
    % testar melhor_pergunta/1
    melhor_pergunta(Result),
    is_list(Result),
    Result = [(CartaA, _, _), (CartaB, _, _)],
    tipos_diferentes(CartaA, CartaB).

test(como_chutar_e_melhor_chute, [setup(reiniciar_estado)]) :-
    % uma carta por tipo não eliminada
    assertz(carta_crime(faca, arma)),
    assertz(carta_crime(hall, lugar)),
    assertz(carta_crime(scarlet, suspeito)),
    % executar melhor_acusacao
    melhor_acusacao(Resultado),
    Resultado = [(A,_,_), (B,_,_), (C,_,_)],
    carta(A, arma),
    carta(B, lugar),
    carta(C, suspeito).

:- end_tests(motor_inferencia_tests).