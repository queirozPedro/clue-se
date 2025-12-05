:- use_module('../prolog/motor_inferencia.pl', [
    descartar/1,
    marcar_evidencia/1,
    tipos_diferentes/2,
    foi_resposta_de_j1/1,
    foi_perguntada/1,
    perguntar/5,
    descartar_com_ou/0,
    como_perguntar/2,
    como_responder/3,
    reiniciar_estado/0
]).

:- begin_tests(testes).

test(descartar_carta, [setup(reiniciar_estado)]) :-
    descartar(faca),
    descartar(cozinha),
    descartar(scarlet).

test(marcar_evidencias, [setup(reiniciar_estado)]) :-
    marcar_evidencia(sala_de_estar),
    marcar_evidencia(white),
    marcar_evidencia(castical).

test(testar_tipos_diferentes, [setup(reiniciar_estado)]) :-
    tipos_diferentes(faca, hall),
    tipos_diferentes(plum, spa),
    \+ tipos_diferentes(faca, revolver).

test(perguntar, [setup(reiniciar_estado)]) :-
    perguntar(j1, j2, faca, spa, spa).

test(teste_carta_perguntada, [setup(reiniciar_estado)]) :-
    perguntar(jogador_0, jogador_1, faca, spa, spa),
    como_perguntar(faca, _).

:- end_tests(testes).