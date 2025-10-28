% ----- DIRETIVAS -----


% Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta(true, false, carta)
:- dynamic pergunta/5.

% carta, tipo
:- dynamic carta/2, descartada/2, evidencia/2.

% jogador, carta
:- dynamic tem_carta/2, nao_tem_carta/2.

% jogador, carta_a, carta_b
:- dynamic pode_ter_ou/3.

% ----- FATOS -----

carta(castical, arma).
carta(corda, arma).
carta(faca, arma).
carta(revolver, arma).

carta(cozinha, lugar).
carta(hall, lugar).
carta(sala_de_estar, lugar).
carta(sala_de_jantar, lugar).
carta(spa, lugar).

carta(green, suspeito).
carta(peacock, suspeito).
carta(plum, suspeito).
carta(mustard, suspeito).
carta(scarlet, suspeito).
carta(white, suspeito).


% ----- REGRAS -----

/*
    descarta a carta:
        SE carta existir e não estiver descartada
        ENTÃO cria o fato descartada
        SENÃO remove o fato descartada

*/
descartar_carta(Carta) :-
    carta(Carta, Tipo), \+ descartada(Carta, Tipo) ->
    (
        assert(descartada(Carta, Tipo))
    );
    (
        retract(descartada(Carta, _Tipo))
    ).
    

/*
    Verifica se os tipos são diferentes
*/
tipos_diferentes(Carta_a, Carta_b) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b.


/*
    pergunta/5 se:
        As cartas existirem e os tipos forem diferentes,
        salva a pergunta em um fato,
        se a resposta for uma das cartas, salva que o j1 tem ela e descarta,
        se a resposta for verdadeira salva que o jogador_b por ter uma das duas,
        senão salva que o jogador_b não tem as duas.
*/
perguntar(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b,
    assert(pergunta(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta)),
    (   
        Resposta == Carta_a ; Resposta == Carta_b
    ) ->
    (
        assert(tem_carta(Jogador_b, Resposta)), % Nesse caso, Jogador_b será j1
        descartar_carta(Resposta)
    );
    (
        Resposta == true ->
        (

            assert(tem_carta_ou(Jogador_b, Carta_a, Carta_b))
        );
        (
            assert(nao_tem_carta(Jogador_b, Carta_a)),
            assert(nao_tem_carta(Jogador_b, Carta_b))
        )
    ).   


/*
    Se um Jogador_a tem a Carta_a e Jogador_b tem (Carta_a ou Carta_b), então descarta a Carta_b
*/
descartar_com_ou :-
    (
        tem_carta(_Jogador_a, Carta_a),
        tem_carta_ou(Jogador_b, Carta_a, Carta_b)
    ) ->
    (
        retract(tem_carta_ou(Jogador_b, Carta_a, Carta_b)),
        assert(tem_carta(Jogador_b, Carta_b)),
        descartar_carta(Carta_b)
    );
    (
        (
            tem_carta(_Jogador_a, Carta_b),
            tem_carta_ou(Jogador_b, Carta_a, Carta_b)
        ) ->
        (
            retract(tem_carta_ou(Jogador_b, Carta_a, Carta_b)),
            assert(tem_carta(Jogador_b, Carta_a)),
            descartar_carta(Carta_a)
        )
    ).


% -------------------------- COMO PERGUNTAR --------------------------

como_perguntar(Status, Status_perguntada, Carta) :-
    carta(Carta, _),
    verifica_condicoes(1, Status, Carta),
    verifica_condicoes_2(1, Status_perguntada, Carta),

% ------------------- Sobre Outros Jogadores -------------------------

num_condicoes(3).

verifica_condicoes(Id, Ultimo_status, Carta) :- 
    num_condicoes(Max),
    Id =< Max,
    condicao_pergunta(Id, _, Carta),
    Next_Id is Id + 1,
    verifica_condicoes(Next_Id, Ultimo_status, Carta), !.

verifica_condicoes(Id, Status, Carta) :-
    Id > 1,
    Prev_Id is Id - 1,
    condicao_pergunta(Prev_Id, Status, Carta), !.


% Verifico se a carta é válida e removo as descartadas e evidências
condicao_pergunta(1, '(1) N foi descartada e n esta com j0', Carta) :- 
    \+ descartada(Carta, _), % não foi descartada
    \+ evidencia(Carta, _), % não é uma evidência do j0
    \+ foi_perguntada(j0 ,Carta).

% Removo as cartas que eu sei que j3 e j3 não tem
condicao_pergunta(2, '(3) Os outros jogadores não tem a carta', Carta) :-
    nao_tem_carta(j2, Carta);
    nao_tem_carta(j3, Carta).

% Removo Cartas que outros jogadores podem ter ou não
condicao_pergunta(3, '(3) N sao cartas que outros jogadores podem ter', Carta) :-
    \+ pode_ter_ou(_, Carta, _),
    \+ pode_ter_ou(_, _, Carta).


% ----------------- Caminho das Cartas Perguntadas -------------------

num_condicoes_2(1).

verifica_condicoes_2(Id, Ultimo_status, Carta) :- 
    num_condicoes_2(Max),
    Id =< Max,
    condicao_pergunta_2(Id, _, Carta),
    Next_Id is Id + 1,
    verifica_condicoes_2(Next_Id, Ultimo_status, Carta), !.

verifica_condicoes_2(Id, Status, Carta) :-
    Id > 1,
    Prev_Id is Id - 1,
    condicao_pergunta_2(Prev_Id, Status, Carta), !.

condicao_pergunta_2(1, '(1) N foi perguntada ainda', Carta) :- 
    \+ descartada(Carta, _), % não foi descartada
    \+ evidencia(Carta, _), % não é uma evidência do j0
    \+ foi_perguntada(_, Carta).

% --------------------------------------------------------------------


foi_perguntada(Jogador, Carta) :-
% Verdadeiro se a carta apareceu em alguma pergunta
    carta(Carta, _Tipo),
    (
        pergunta(Jogador, _, Carta, _, _);
        pergunta(Jogador, _, _, Carta, _)
    ).


como_responder(Carta_a, Carta_b) :-
    (
        carta(Carta_a, Tipo_a),
        carta(Carta_b, Tipo_b),
        Tipo_a \= Tipo_b
    ) ->
    (
        (
            evidencia(Carta_a, _), 
            evidencia(Carta_b, _)
        ) ->
        (
            format("Ambas as cartas")
            % Aqui preciso pensar em uma forma de responder com base na quantidade das cartas
        );
        (
            evidencia(Carta_a, _), format("Resposta: ~w", [Carta_a]);
            evidencia(Carta_b, _), format("Resposta: ~w", [Carta_b])
        )
    ).