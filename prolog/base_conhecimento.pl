% ----- DIRETIVAS -----


% Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta(true, false, carta)
:- dynamic pergunta/5.

% carta, tipo
:- dynamic carta/2, descartada/2, evidencia/2.

% jogador, carta
:- dynamic tem_carta/2, nao_tem_carta/2.

% jogador, carta_a, carta_b
:- dynamic pode_ter_carta/3.


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
    descarta a carta se:
        A carta existir no fato carta/2,
        ela não já estiver sido descartada/2,
        descarta ela.

*/
descartar(Carta) :-
    carta(Carta, Tipo),
    \+ descartada(Carta, Tipo),
    assert(descartada(Carta, Tipo)).
    

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
        descartar(Resposta)
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
        descartar(Carta_b)
    );
    (
        (
            tem_carta(_Jogador_a, Carta_b),
            tem_carta_ou(Jogador_b, Carta_a, Carta_b)
        ) ->
        (
            retract(tem_carta_ou(Jogador_b, Carta_a, Carta_b)),
            assert(tem_carta(Jogador_b, Carta_a)),
            descartar(Carta_a)
        )
    ).


/*
    Mostra todas as cartas que podem ser perguntadas, mostrando quais cartas tem mais chances de estar com j1
*/
como_perguntar(Carta) :-
    (
        findall(Carta, tem_carta(j1, Carta), Lista),
        length(Lista, Quantidade), Quantidade < 3
    ) -> 
    (
        carta(Carta, _), % Pega as cartas
        \+ descartada(Carta, _), % Tirando as que já foram descartadas
        filtrar_cartas_j1(Carta),
        (         
            % Não está com os outros jogadores
            (nao_j2_e_j3(Carta) -> format("nao j2 e j3 : ~w", [Carta]));    
            % Não está com pelo um dos outros jogadores
            (nao_j2_ou_j3(Carta) -> format("nao j2 ou j3 : ~w", [Carta])); 
            % Não está com j1
            format("nao j1 : ~w", [Carta])
        )
    );
    write("Perguntas esgotadas").


nao_j2_ou_j3(Carta) :-
% Verdadeiro se estiver com j2 ou com j3
    nao_tem_carta(j2, Carta); nao_tem_carta(j3, Carta).


nao_j2_e_j3(Carta) :-
% Verdadeiro se estiver com j2 e j3
    nao_tem_carta(j2, Carta), nao_tem_carta(j3, Carta).


filtrar_cartas_j1(Carta) :-
% Filtradas as cartas que sabemos que estão e não estão com j1
    \+ tem_carta(j1, Carta), % Tirando as cartas que j1 tem
    \+ nao_tem_carta(j1, Carta). % Tirando as cartas que j1 não tem


foi_perguntada(Carta) :-
% Verdadeiro se a carta apareceu em alguma pergunta
    carta(Carta, _Tipo),
    (
        pergunta(_, _, Carta, _, _);
        pergunta(_, _, _, Carta, _)
    ).


marcar_evidencia(Carta) :-
    carta(Carta, Tipo),
    assert(evidencia(Carta, Tipo)),
    descartar(Carta).


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

% como_acusar :-