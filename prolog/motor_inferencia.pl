%  ---------------- Declaração do Módulo ----------------

:- module(motor_inferencia, [

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


% ---------------- Diretivas ----------------


% carta, tipo
:- dynamic carta_eliminada/2, carta_evidencia/2, carta_crime/2.

% Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta(true, false, carta)
:- dynamic pergunta/5.

% jogador, carta
:- dynamic tem_carta/2, nao_tem_carta/2.

% jogador, carta_a, carta_b
:- dynamic pode_ter_carta/3.


% ---------------- Fatos estáticos ----------------


% nome, tipo 
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


% ---------------- Regras Básicas ----------------


% Regra que elimina uma carta.
eliminar_carta(Carta) :-
    carta(Carta, Tipo),
    \+ carta_eliminada(Carta, _), % Essa verificação impede a criação de fatos duplicados
    assertz(carta_eliminada(Carta, Tipo)).


% Marca a carta como evidencia.
marcar_evidencia(Carta) :-
    carta(Carta, Tipo),
    \+ carta_evidencia(Carta, _),
    assertz(tem_carta(jogador_0, Carta)),
    assertz(carta_evidencia(Carta, Tipo)).


% Verifica se duas cartas são de tipos diferentes.
tipos_diferentes(Carta_a, Carta_b) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b.


% Verifica a quem a carta foi perguntada.
foi_perguntada(Jogador, Carta) :-
    carta(Carta, _),
        pergunta(_, Jogador, Carta, _, _);
        pergunta(_, Jogador, _, Carta, _).


% ----------------- Visualizar Cartas ------------------

% Percorre as cartas verificando qual seu status.
consultar_anotacoes(Resultado) :-
    findall(
        (Carta, Info),
        (
            carta(Carta, _),
            status_carta(Carta, Info)
        ),
        Resultado).


status_carta(Carta, "carta_crime") :-
    carta_crime(Carta, _), !.

status_carta(Carta, "carta_evidencia") :-
    carta_evidencia(Carta, _), !.

status_carta(Carta, "carta_eliminada") :-
    carta_eliminada(Carta, _), !.

status_carta(Carta, "sem_info") :-
    carta(Carta, _), !.


% ---------------- Regras de Informação ----------------
% Regras que auxiliam no gerenciamento de anotações

% Regra que registra as perguntas feitas no jogo.
registrar_pergunta(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta) :-
    tipos_diferentes(Carta_a, Carta_b),
    assertz(pergunta(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta)),
    (   
        (Resposta == Carta_a ; Resposta == Carta_b) -> 
        (
            assertz(tem_carta(Jogador_b, Resposta)),
            eliminar_carta(Resposta)
        ) ;
        (
            Resposta == true ->
            (
                assertz(pode_ter_carta(Jogador_b, Carta_a, Carta_b))
            ) ;
            (   
                Resposta == false ->
                (
                    assertz(nao_tem_carta(Jogador_b, Carta_a)),
                    assertz(nao_tem_carta(Jogador_b, Carta_b))
                )
            )
        )
    ).

% executa inferencias sobre a memoria de trabalho afim de realizar deduções sobre o jogo
executar_inferencias():-
    (inferir_posse_cartas() ; true),
    inferir_carta_crime().

% executa inferencias afim de realizar deduções sobre a posse de cartas
inferir_posse_cartas :-
    (
        tem_carta(_Jogador_a, Carta_a),
        pode_ter_carta(Jogador_b, Carta_a, Carta_b)
    ) ->
    (
        retract(pode_ter_carta(Jogador_b, Carta_a, Carta_b)),
        assertz(tem_carta(Jogador_b, Carta_b)),
        eliminar_carta(Carta_b)
    );
    (
        (
            tem_carta(_Jogador_a, Carta_b),
            pode_ter_carta(Jogador_b, Carta_a, Carta_b)
        ) ->
        (
            retract(pode_ter_carta(Jogador_b, Carta_a, Carta_b)),
            assertz(tem_carta(Jogador_b, Carta_a)),
            eliminar_carta(Carta_a)
        )
    ).

% Fatos que auxiliam na inferencia de crime
eh_tipo(arma, (_, arma)).
eh_tipo(lugar, (_, lugar)).
eh_tipo(suspeito, (_, suspeito)).

% Inferir carta crime
inferir_carta_crime() :-
    findall(
        (Carta, Tipo),
        (
            carta(Carta, Tipo),
            \+ carta_evidencia(Carta, Tipo),
            \+ carta_eliminada(Carta, Tipo),
            \+ carta_crime(Carta, Tipo)
        ),
        Cartas_Filtradas),

    forall(
        member(Tipo, [arma, lugar, suspeito]),
        ( 
            include(eh_tipo(Tipo), Cartas_Filtradas, CartasDoTipo),
            length(CartasDoTipo, N),
            N =:= 1 -> 
            CartasDoTipo = [(Carta, Tipo)],
            assertz(carta_crime(Carta, Tipo))
            ; true
        )
    ).


% ---------------- Como Perguntar ----------------


% Analisa a lista de cartas e retorna as melhores opções de carta para perguntar
melhor_pergunta(Resultado) :-
    como_perguntar(Lista),
    Lista = [P_a-(Carta_a, Info_a) | Restante],

    member(P_b-(Carta_b, Info_b), Restante),
    tipos_diferentes(Carta_a, Carta_b),
    !,

    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),

    % alternativas de Carta_a com mesmo peso P_a
    findall(
        (Carta_alt_a, Info_alt_a),
        (
            member(P_a-(Carta_alt_a, Info_alt_a), Lista),
            Carta_alt_a \= Carta_a,
            carta(Carta_alt_a, Tipo_a)
        ),
        Outras_a),

    % alternativas de Carta_b com mesmo peso P_b
    findall(
        (Carta_alt_b, Info_alt_b),
        (
            member(P_b-(Carta_alt_b, Info_alt_b), Lista),
            Carta_alt_b \= Carta_b,
            carta(Carta_alt_b, Tipo_b)
        ),
        Outras_b),

    Resultado = [(Carta_a, Info_a, Outras_a),  (Carta_b, Info_b, Outras_b)].

% Percorre todas as cartas verificando seu status e colocanndo em ordem de prioridade
como_perguntar(Resultado) :-
    findall(
        P-(Carta,Info),
        (
            carta(Carta,_), 
            avaliar_carta_pergunta(Carta, P, Info)
        ),
        Lista),
    keysort(Lista, Ordenada),
    Resultado = Ordenada.

avaliar_carta_pergunta(Carta, 7, "carta eliminada") :- % Filtro
    carta_eliminada(Carta, _), !.

avaliar_carta_pergunta(Carta, 7, "carta de evidencia") :- % Filtro
    carta_evidencia(Carta, _), !.

avaliar_carta_pergunta(Carta, 7, "carta do crime") :- % Filtro
    carta_crime(Carta, _), !.

avaliar_carta_pergunta(Carta, 7,  "nao possuida pelo jogador 1") :-
    nao_tem_carta(jogador_1, Carta), nao_tem_carta(jogador_1, Carta), !.

avaliar_carta_pergunta(Carta, 1, "nao possuida pelos jogadores 2 e 3") :- 
    nao_tem_carta(jogador_2, Carta), nao_tem_carta(jogador_3, Carta), !.

avaliar_carta_pergunta(Carta, 2,  "nao possuida pelo jogador 2") :-
    nao_tem_carta(jogador_2, Carta), !.

avaliar_carta_pergunta(Carta, 2, "nao possuida pelo jogador 3") :-
    nao_tem_carta(jogador_3, Carta), !.

avaliar_carta_pergunta(Carta, 3, "nao questionada") :-
    \+ foi_perguntada(_, Carta), !.

avaliar_carta_pergunta(Carta, 4, "o jogador 2 pode ter") :-
    (pode_ter_carta(jogador_2, Carta, _) ; pode_ter_carta(jogador_2, _, Carta)), !.

avaliar_carta_pergunta(Carta, 5, "o jogador 3 pode ter") :-
    (pode_ter_carta(jogador_3, Carta, _) ; pode_ter_carta(jogador_3, _, Carta)), !.

avaliar_carta_pergunta(Carta, 6, "citada em pergunta ao jogador 1") :-
    foi_perguntada(jogador_1, Carta), !.


% ---------------- Como Responder ----------------
% Suspeito > Lugar > Arma

prioridade_resposta(Carta, 1) :- carta(Carta, suspeito), !.
prioridade_resposta(Carta, 2) :- carta(Carta, lugar), !.
prioridade_resposta(Carta, 3) :- carta(Carta, arma).

como_responder(Carta_a, Carta_b, "nao posso te ajudar") :-
    tipos_diferentes(Carta_a, Carta_b), 
    \+ carta_evidencia(Carta_a, _),
    \+ carta_evidencia(Carta_b, _), !.

como_responder(Carta_a, Carta_b, "carta_a") :-
    tipos_diferentes(Carta_a, Carta_b), 
    carta_evidencia(Carta_a, _),
    \+ carta_evidencia(Carta_b, _), !.

como_responder(Carta_a, Carta_b, "carta_b") :-
    tipos_diferentes(Carta_a, Carta_b), 
    carta_evidencia(Carta_b, _),
    \+ carta_evidencia(Carta_a, _), !.

como_responder(Carta_a, Carta_b, Resposta) :-
    tipos_diferentes(Carta_a, Carta_b), 
    carta_evidencia(Carta_a, _),
    carta_evidencia(Carta_b, _),
    
    prioridade_resposta(Carta_a, P_a),
    prioridade_resposta(Carta_b, P_b),
    (
        P_a =< P_b 
        -> Resposta = "carta_a"
        ;  Resposta = "carta_b"
    ).


% ---------------- Como Chutar ----------------

melhor_acusacao(Resultado) :-
    como_acusar(Lista),
    Lista = [P_a-(Carta_a, Info_a) | Restante],

    member(P_b-(Carta_b, Info_b), Restante),
    member(P_c-(Carta_c, Info_c), Restante),
    tipos_diferentes(Carta_a, Carta_b),
    tipos_diferentes(Carta_b, Carta_c),
    tipos_diferentes(Carta_c, Carta_a),
    !,

    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    carta(Carta_c, Tipo_c),

    % alternativas de Carta_a com mesmo peso P_a
    findall(
        (Carta_alt_a, Info_alt_a),
        (
            member(P_a-(Carta_alt_a, Info_alt_a), Lista),
            Carta_alt_a \= Carta_a,
            carta(Carta_alt_a, Tipo_a)
        ),
        Outras_a),

    % alternativas de Carta_b com mesmo peso P_b
    findall(
        (Carta_alt_b, Info_alt_b),
        (
            member(P_b-(Carta_alt_b, Info_alt_b), Lista),
            Carta_alt_b \= Carta_b,
            carta(Carta_alt_b, Tipo_b)
        ),
        Outras_b),
    
    % alternativas de Carta_b com mesmo peso P_c
    findall(
        (Carta_alt_c, Info_alt_c),
        (
            member(P_c-(Carta_alt_c, Info_alt_c), Lista),
            Carta_alt_c \= Carta_c,
            carta(Carta_alt_c, Tipo_c)
        ),
        Outras_c),

    Resultado = [
        (Carta_a, Info_a, Outras_a),  
        (Carta_b, Info_b, Outras_b),  
        (Carta_c, Info_c, Outras_c)
    ].

como_acusar(Resultado) :-
    findall(
            P-(Carta,Info),
            (
                carta(Carta,_), 
                avaliar_carta_acusacao(Carta, P, Info)
            ),
            Lista),
    keysort(Lista, Ordenada),
    Resultado = Ordenada.

avaliar_carta_acusacao(Carta, 5, "carta eliminada") :- % Filtro
    carta_eliminada(Carta, _), !.

avaliar_carta_acusacao(Carta, 5, "consta nas evidencias") :- % Filtro
    carta_evidencia(Carta, _), !.

avaliar_carta_acusacao(Carta, 1, "faz parte do crime") :-
    carta_crime(Carta, _), !.

avaliar_carta_acusacao(Carta, 2, "outros 2 jogadores nao tem essa carta") :-
    \+ carta_eliminada(Carta,_), 
    aggregate_all(count, nao_tem_carta(_, Carta), N),
    N =:= 2, !.

avaliar_carta_acusacao(Carta, 3, "outro jogador nao tem essa carta") :-
    \+ carta_eliminada(Carta,_), 
    nao_tem_carta(_, Carta), !.

avaliar_carta_acusacao(Carta, 4, "sem info") :- 
    carta(Carta, _).


% Regra que reinicia o estado da base de conhecimento
reiniciar_estado :-
    retractall(pergunta(_, _, _, _, _)),
    retractall(carta_eliminada(_, _)),
    retractall(carta_evidencia(_, _)),
    retractall(carta_crime(_, _)),
    retractall(tem_carta(_, _)),
    retractall(nao_tem_carta(_, _)),
    retractall(pode_ter_carta(_, _, _)).