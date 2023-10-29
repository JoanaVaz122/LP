% Nome: Joana Vaz, numero : ist1106078

:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ["dados.pl"], ["keywords.pl"]. % ficheiros a importar.


%############################################################################################################################
%#############################################  3.1 Qualidade dos dados #####################################################
%############################################################################################################################

%----------------------------------------------------------------------------------------------------------------------------

%eventosSemSalas/1

/*
esta funcao retorna uma lista 'EventosSemSala' que contem todos os IDs, sem repeticoes e ordenados
de todos os eventos que nao tem sala.
O predicado e verdadeiro se EventosSemSala e uma lista com os eventos sem sala
*/

eventosSemSalas(EventosSemSala):-
    findall(ID, evento(ID,_,_,_,semSala), EventosSemSala_aux), 
    sort(EventosSemSala_aux, EventosSemSala). 

%----------------------------------------------------------------------------------------------------------------------------

%eventosSemSalasDiaSemana/2

/*
esta funcao retorna uma lista 'EventosSemSala' que contem todos os IDs, sem repeticoes e ordenados
 de todos os eventos que nao tem sala e acontecem num determinado dia da semana.
O predicado e verdadeiro se DiaDaSemana e um dia da semana e Eventos sem sala e uma lista dos eventos sem sala no dia da semana
*/

eventosSemSalasDiaSemana(DiaDaSemana, EventosSemSala):-
    findall(ID, horario(ID,DiaDaSemana,_,_,_,_), Eventos_no_dia), %todos os eventos de um determinado dia
    eventosSemSalas(Eventos_sem_sala),  %todos os eventos sem sala
    intersection(Eventos_no_dia, Eventos_sem_sala, EventosSemSala_aux), %intersecao de todos os eventos sem sala com os eventos de um determinado dia
    sort(EventosSemSala_aux, EventosSemSala). 

%----------------------------------------------------------------------------------------------------------------------------

%eventosSemSalasPeriodo/2

/*
esta funcao recebe uma lista de periodos e retorna todos os IDs dos eventos sem sala que acontecem
nesses mesmos periodos, ordenados e sem repeticoes.
O predicado e verdadeiro se ListaPeriodos e uma lista de periodos e EventosSemSala e uma lista dos eventos sem sala nos periodos da lista
*/

eventosSemSalasPeriodo([],[]):-!.
eventosSemSalasPeriodo([Periodo|Resto_dos_Periodos],EventosSemSala):-
    (Periodo == p1; Periodo == p2), %escolha dos periodos por causa dos semestres
    findall(ID, (horario(ID,_,_,_,_,p1_2); horario(ID,_,_,_,_,Periodo)),  Eventos_no_periodo_semestre), %eventos no periodo e no semestre
    findall(ID, evento(ID,_,_,_,semSala), Eventos_sem_sala), %eventos sem sala
    intersection(Eventos_no_periodo_semestre, Eventos_sem_sala, Eventos_sem_sala_periodo_semestre), %eventos sem sala no periodo e no semestre
    eventosSemSalasPeriodo(Resto_dos_Periodos, Eventos_sem_sala_aux), %chamar a funcao para os restantes valores da lista
    append([Eventos_sem_sala_periodo_semestre, Eventos_sem_sala_aux], EventosSemSala1), %ir adicionando tudo numa lista auxiliar
    sort(EventosSemSala1,EventosSemSala). %ordenar a lista

eventosSemSalasPeriodo([Periodo|Resto_dos_Periodos],EventosSemSala):-
    (Periodo == p3; Periodo == p4),
    findall(ID, (horario(ID,_,_,_,_,p3_4); horario(ID,_,_,_,_,Periodo)),  Eventos_no_periodo_semestre), 
    findall(ID, evento(ID,_,_,_,semSala), Eventos_sem_sala), 
    intersection(Eventos_no_periodo_semestre, Eventos_sem_sala, Eventos_sem_sala_periodo_semestre), 
    eventosSemSalasPeriodo(Resto_dos_Periodos, Eventos_sem_sala_aux), 
    append([Eventos_sem_sala_periodo_semestre, Eventos_sem_sala_aux], EventosSemSala1), 
    sort(EventosSemSala1,EventosSemSala). 

%----------------------------------------------------------------------------------------------------------------------------

%############################################################################################################################
%###############################################  3.2 Pesquisas simples #####################################################
%############################################################################################################################

%----------------------------------------------------------------------------------------------------------------------------

%organizaEventos/3

/*
esta funcao recebe uma lista de IDs e um periodo e devolve uma lista 'EventosNoPeriodo' em que aparecem os
IDs que estao continos no periodo escolhido, ordenados e sem repeticoes.
O predicado e verdadeiro se ListaEventos e uma lista de IDs, Periodo e um periodo e EventosNoPeriodo e uma lista dos IDs do periodo
*/

organizaEventos([],_, []):-!.
organizaEventos([Primeiro_ID|Resto_IDs], Periodo, EventosNoPeriodo):-
    (Periodo == p1; Periodo == p2), %tem em atencao os semestres
    (horario(Primeiro_ID,_,_,_,_,Periodo);horario(Primeiro_ID,_,_,_,_,p1_2)), %verifica de o ID esta no periodo ou no semestre 
    organizaEventos(Resto_IDs, Periodo, Eventos_no_periodo_aux), %volta a chamar a funcao para verificar para os restantes IDs
    append([Primeiro_ID], Eventos_no_periodo_aux, EventosNoPeriodo). %se o ID estiver contido no periodo inserido, e adicionado a lista

organizaEventos([Primeiro_ID|Resto_IDs], Periodo, EventosNoPeriodo):-
    (Periodo == p3; Periodo == p4),
    (horario(Primeiro_ID,_,_,_,_,Periodo);horario(Primeiro_ID,_,_,_,_,p3_4)),
    organizaEventos(Resto_IDs, Periodo, Eventos_no_periodo_aux),
    append([Primeiro_ID], Eventos_no_periodo_aux, EventosNoPeriodo).

organizaEventos([_|Resto_IDs], Periodo, EventosNoPeriodo):- %caso o elemento da lista nao seja um ID, a funcao apenas passa a frente e     
    organizaEventos(Resto_IDs, Periodo, EventosNoPeriodo).                                    %continua a recursao para os outros IDs.

%----------------------------------------------------------------------------------------------------------------------------

%eventosMenoresQue/2

/*
esta funcao recebe uma duracao e retorna uma lista dos IDs dos eventos, ordenados e sem repeticoes, que tenham
uma duraca igual ou inferior a duracao inserida.
O predicado e verdadeiro se duracao e uma numero real e ListaEventosMenoresQue e a lista dos eventos com a duracao menor que a duracao
de input
*/

eventosMenoresQue(Duracao, ListaEventosMenoresQue):-
    findall(ID, (horario(ID,_,_,_,Duracao_aux,_), Duracao_aux =< Duracao), ListaEventosMenoresQue). 

%----------------------------------------------------------------------------------------------------------------------------

%eventosMenoresQueBool/2

/*
esta funcao recebe um ID e uma duracao, e retorna True or Flase consoante a duracao do ID e menor ou igual a duracao.
Se a duracao do ID for maior que o input da duracao, retorna false, caso contrario, retorna True.
O predicado e verdadeiro se ID e um ID e a duracao e um numero real
*/

eventosMenoresQueBool(ID, Duracao):-
    horario(ID,_,_,_,Duracao_aux,_), Duracao_aux =< Duracao.
   
%----------------------------------------------------------------------------------------------------------------------------

%procuraDisciplinas/2

/*
esta funcao recebe um curso e retorna uma lista com todas as disciplinas que esse curso tem ao longo dos anos.
A lista de retorno esta ordenada e sem repeticoes.
o predicado e verdadeiro se o Curso e um curso e a ListaDisciplinas e uma lista com as disciplinas dos curso
*/

procuraDisciplinas(Curso, ListaDisciplinas):-
    findall(Disciplinas, (turno(ID,Curso,_,_), evento(ID,Disciplinas,_,_,_)), Disciplinas_Lista),
    sort(Disciplinas_Lista, ListaDisciplinas). 

%----------------------------------------------------------------------------------------------------------------------------

%organizaDisciplinas/3

/*
esta funcao recebe uma lista com disciplinas e um curso e retorna uma outra lista com duas listas la dentro. A primeira
corresponde as disciplinas do primeiro semestre e a segunda as disciplinas do segundo semestre. Sendo assim, e retorno desta 
funcao e uma lista de listas em que contem as cadeiras correspondentes a cada curso separadas conforme pertencem ao
primeiro e ao segundo semestre.
o predicado e verdadeiro se ListaDisciplinas e uma lista de disciplinas, Curso e uma curso e Semestres e uma lista com duas la dentro
que representam que disciplinas pertencem ao primeiro e ao segundo semestre
*/

organizaDisciplinas([],_,[[],[]]):-!.
organizaDisciplinas([PrimeiraDisciplina|RestoDisciplinas], Curso, [[PrimeiraDisciplina|PrimeiroSemestre],SegundoSemestre]):-
%se isto for verdade a funcao adiciona a disciplina a primeira lista que esta dentro da lista de retorno
    evento(ID,PrimeiraDisciplina,_,_,_),  
    turno(ID,Curso,_,_), member(Periodo, [p1,p2,p1_2]), %verifica se a funcao pertence ao primeiro semestre
    horario(ID,_,_,_,_,Periodo),
    organizaDisciplinas(RestoDisciplinas, Curso, [PrimeiroSemestre1, SegundoSemestre1]),
    sort(PrimeiroSemestre1, PrimeiroSemestre),
    sort(SegundoSemestre1, SegundoSemestre). %ordena alfabeticamente as disciplinas

organizaDisciplinas([PrimeiraDisciplina|RestoDisciplinas], Curso, [PrimeiroSemestre,[PrimeiraDisciplina|SegundoSemestre]]):-
%se isto for verdade a funcao adiciona a disciplina a segunda lista que esta dentro da lista de retorno
    evento(ID,PrimeiraDisciplina,_,_,_),
    turno(ID,Curso,_,_), member(Periodo, [p3,p4,p3_4]), %verifica se a funcao pertence ao segundo semestre
    horario(ID,_,_,_,_,Periodo),
    organizaDisciplinas(RestoDisciplinas, Curso, [PrimeiroSemestre1, SegundoSemestre1]),
    sort(PrimeiroSemestre1, PrimeiroSemestre),
    sort(SegundoSemestre1, SegundoSemestre). %ordena alfabeticamente as disciplinas

%----------------------------------------------------------------------------------------------------------------------------

% horasCurso/5

/*
esta funcao retorna o numero de horas associados a um evento tendo em conta o periodo e o curso em que esse evento esta
inserido
o predicado e verdadeiro se Periodo for um periodo, Curso for um curso, o Ano for um interio positivo e o TotalHoras
for um inteiro positivo
*/

auxiliar([],_, TotalHoras, TotalHoras):-!.
auxiliar([Primeiro_ID| Resto_IDs], Periodo, Acumulador, TotalHoras):-
    (Periodo == p1; Periodo == p2), %verifica os periodos e semestres
    findall(Horas, (horario(Primeiro_ID,_,_,_,Horas,Periodo) ; horario(Primeiro_ID,_,_,_,Horas,p1_2)), Lista_Horas_de_cada_ID), %adiciona na lista a duracao correspondente a cada ID
    sum_list(Lista_Horas_de_cada_ID, Soma_das_horas),  %soma a lista com as duracoes
    Novo_acumulador is Acumulador + Soma_das_horas, %atualiza o contador das duracoes criando um novo acumulador com o valor atualizado 
    auxiliar(Resto_IDs, Periodo, Novo_acumulador, TotalHoras). %chama a funcao de novo para fazer para os restantes IDs 

auxiliar([Primeiro_ID| Resto_IDs], Periodo, Acumulador, TotalHoras):-
    (Periodo == p3; Periodo == p4),
    findall(Horas, (horario(Primeiro_ID,_,_,_,Horas,Periodo) ; horario(Primeiro_ID,_,_,_,Horas,p3_4)), Lista_Horas_de_cada_ID),
    sum_list(Lista_Horas_de_cada_ID, Soma_das_horas), 
    Novo_acumulador is Acumulador + Soma_das_horas, 
    auxiliar(Resto_IDs, Periodo, Novo_acumulador, TotalHoras). 

horasCurso(Periodo, Curso, Ano, TotalHoras):-
    findall(ID, turno(ID,Curso,Ano,_), Lista_de_IDs), 
    sort(Lista_de_IDs, Lista_de_IDs_sem_repetidos), 
    auxiliar(Lista_de_IDs_sem_repetidos, Periodo, 0, TotalHoras). %contador inicializado a 0.

%----------------------------------------------------------------------------------------------------------------------------

% evolucaoHorasCurso/2

/*
esta funcao retorna uma lista de tuplos que contem dentro de si o ano, o curso e o numero de horas associadas ao curso,
num determinado ano, periodo e curso respetivamente
o predicado e verdadeiro se Curso for um curso e Evolucao for uma lista de tuplos
*/

evolucaoHorasCurso(Curso, Evolucao):-
    findall((Ano, Periodo, NumHoras), (between(1, 3, Ano), member(Periodo, [p1, p2, p3, p4]), horasCurso(Periodo, Curso, Ano, NumHoras)), Evolucao).

%----------------------------------------------------------------------------------------------------------------------------

%############################################################################################################################
%###########################################  3.3 Ocupacoes criticas de salas ###############################################
%############################################################################################################################

%----------------------------------------------------------------------------------------------------------------------------

%ocupaSlot/5

/*
esta funcao retorna o valor da diferenca entre o menor valor das horas do fim dos eventos e o maior valor 
do inicio dos eventos
o predicado e verdadeiro se HoraInicioDada, HoraFimDada,HoraInicioEvento,HoraFimEvento, Horas forem numeros reais
*/

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas):-
    Maior_inicio is max(HoraInicioDada, HoraInicioEvento),
    Menor_fim is min(HoraFimDada, HoraFimEvento),
    Horas is (Menor_fim - Maior_inicio),
    Horas >= 0.

%----------------------------------------------------------------------------------------------------------------------------

%numHorasOcupadas/6

/*
esta funcao retorna  o numero de horas ocupadas nas salas do tipo TipoSala, no intervalo de tempo definido entre HoraInicio
e HoraFim, no dia da semana DiaSemana, e no periodo Periodo.
o predicado e verdadeiro se Periodo for uma periodo, Tipo de sala for o tipo de uma sala, o DiaSemana for um dia da semana,
HoraInicio, HoraFim e SomaHoras forem numeros reais positivos
*/

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras):-
    (Periodo == p1 ; Periodo == p2), %especificar o periodo, para depois bater certo o semestre
    salas(TipoSala, Lista_de_Salas), %tem em consideracao as salas
    findall(Horas, ((horario(ID,DiaSemana,Hora_Inicio_Descobrir,Hora_Fim_Descobrir,_,Periodo);horario(ID,DiaSemana,Hora_Inicio_Descobrir,Hora_Fim_Descobrir,_,p1_2)), 
    ocupaSlot(HoraInicio, HoraFim, Hora_Inicio_Descobrir, Hora_Fim_Descobrir, Horas),
    (member(Sala, Lista_de_Salas),evento(ID,_,_,_,Sala))), Lista_de_Horas),
    sum_list(Lista_de_Horas, SomaHoras).
    
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras):-
    (Periodo == p3 ; Periodo == p4),
    salas(TipoSala, Lista_de_Salas),
    findall(Horas, ((horario(ID,DiaSemana,Hora_Inicio_Descobrir,Hora_Fim_Descobrir,_,Periodo);horario(ID,DiaSemana,Hora_Inicio_Descobrir,Hora_Fim_Descobrir,_,p3_4)),
    ocupaSlot(HoraInicio, HoraFim, Hora_Inicio_Descobrir, Hora_Fim_Descobrir, Horas),
    (member(Sala, Lista_de_Salas),evento(ID,_,_,_,Sala))), Lista_de_Horas),
    sum_list(Lista_de_Horas, SomaHoras).

%----------------------------------------------------------------------------------------------------------------------------

%ocupacaoMax/5

/*
esta funcao retorna o valor maximo de horas ocupadas por determinadas salas no intervalo de tempo definido 
entre HoraInicio e HoraFim. 
o predicado e verdadeiro se TipoSala for um tipo de sala, HoraInicio, HoraFim e Max sao numeros reais positivos
*/

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max):-
    salas(TipoSala, N_salas),
    length(N_salas, Tamanho),
    Max is (HoraFim - HoraInicio) * Tamanho.

%----------------------------------------------------------------------------------------------------------------------------

%percentagem/3

/*
esta funcao retorna o quociente entre o somaHoras e o Max.
o predicado e verdadeiro se SomaHoras,Max,Percentagem forem numeros reais  
*/

percentagem(SomaHoras, Max, Percentagem):-
    Percentagem is SomaHoras/Max * 100.

%----------------------------------------------------------------------------------------------------------------------------

%ocupacaoCritica/4

/*
a funcao retorna uma lista ordenada de tuplos do tipo casosCriticos(DiaSemana, TipoSala, Percentagem) em que DiaSemana, 
TipoSala e Percentagem sao, respectivamente, um dia da semana, um tipo de sala e a sua percentagem de ocupacao, no intervalo
de tempo entre HoraInicio e HoraFim, e supondo que a percentagem de ocupacao relativa a esses elementos esta acima de um 
dado valor critico (Threshold).
o predicado e verdadeiro se  HoraInicio, HoraFim,Threshold forem numeros reais e Resultados for uma lista de tuplos
*/

ocupacaoCritica(HoraInicio, HoraFim, Threshold, Resultados):-
    findall(casosCriticos(DiaSemana, TipoSala, Per), (member(DiaSemana,[segunda-feira,terca-feira,quarta-feira,quinta-feira,sexta-feira, sabado]),member(Periodo, [p1,p2,p3,p4]), 
    numHorasOcupadas(Periodo,TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras),ocupacaoMax(TipoSala, HoraInicio, HoraFim, Horas_Max),
    percentagem(SomaHoras, Horas_Max, Percentagem),ceiling(Percentagem,Per),Percentagem > Threshold), Resultado_Lista),
    sort(Resultado_Lista,Resultados).

%----------------------------------------------------------------------------------------------------------------------------

%############################################################################################################################
%#######################################  3.4 And now for something completely different ####################################
%############################################################################################################################

%----------------------------------------------------------------------------------------------------------------------------

%o ocupacaoMesa/3

/*
esta funcao recebe 2 listas, a primeira, a ListaPessoas e a lista com o nome das pessoas a sentar  mesa, a 
ListaRestricoes e a lista de restricoes a verificar. Como retorno a funcao devolve uma lista de listas, cupacaoMesa
em que a primeira lista tem as pessoas de um lado da mesa [1,2,3], a segunda as pessoas que estao a cabeceira [4,5] e a
terceira lista as pessoas do outro lado da mesa [6,7,8]. Sendo assim, a funcao aplica a lista com os nomes das pessoas todas
as restricoes a considerar e uma solucao de como sentar as pessoas.
o predicado e verdadeiro se ListaPessoas, ListaRestricoes e OcupacaoMesa forem listas
*/

%Todas as restricoes

%restricao de so haver uma pessoa na cabeceira
cab1(NomePessoa, [[_,_,_], [NomePessoa,_], [_,_,_]]).

%restricao de so haver uma pessoa na outra cabeceira
cab2(NomePessoa, [[_,_,_], [_,NomePessoa], [_,_,_]]).

%restricoes para que quem esta na cabeceira ter uma pessoa a direira
honra(NomePessoa1, NomePessoa2, [[_,_,_], [NomePessoa1,_], [NomePessoa2,_,_]]).
honra(NomePessoa1, NomePessoa2, [[_,_,NomePessoa2], [_,NomePessoa1], [_,_,_]]).

%restricoes para uma pessoa ter outra pessoa ao lado
lado(NomePessoa1, NomePessoa2, [[NomePessoa1,NomePessoa2,_], [_,_], [_,_,_]]).
lado(NomePessoa1, NomePessoa2, [[NomePessoa2,NomePessoa1,_], [_,_], [_,_,_]]).
lado(NomePessoa1, NomePessoa2, [[_,NomePessoa1,NomePessoa2], [_,_], [_,_,_]]).
lado(NomePessoa1, NomePessoa2, [[_,NomePessoa2,NomePessoa1], [_,_], [_,_,_]]).
lado(NomePessoa1, NomePessoa2, [[_,_,_], [_,_], [NomePessoa1,NomePessoa2,_]]).
lado(NomePessoa1, NomePessoa2, [[_,_,_], [_,_], [NomePessoa2,NomePessoa1,_]]).
lado(NomePessoa1, NomePessoa2, [[_,_,_], [_,_], [_,NomePessoa1,NomePessoa2]]).
lado(NomePessoa1, NomePessoa2, [[_,_,_], [_,_], [_,NomePessoa2,NomePessoa1]]).

%restricao que nega as restricoes de cima, ou seja, sao todas as possibilidades de nao ter uma certa pessoa ao lado
naoLado(NomePessoa1, NomePessoa2, OcupacaoMesa):-
    \+ lado(NomePessoa1, NomePessoa2, OcupacaoMesa).

%restricoes para estar frente a frente com alguem
frente(NomePessoa1, NomePessoa2, [[NomePessoa1,_,_], [_,_], [NomePessoa2,_,_]]).
frente(NomePessoa1, NomePessoa2, [[NomePessoa2,_,_], [_,_], [NomePessoa1,_,_]]).
frente(NomePessoa1, NomePessoa2, [[_,NomePessoa1,_], [_,_], [_,NomePessoa2,_]]).
frente(NomePessoa1, NomePessoa2, [[_,NomePessoa2,_], [_,_], [_,NomePessoa1,_]]).
frente(NomePessoa1, NomePessoa2, [[_,_,NomePessoa1], [_,_], [_,_,NomePessoa2]]).
frente(NomePessoa1, NomePessoa2, [[_,_,NomePessoa2], [_,_], [_,_,NomePessoa1]]).

%restricoes para nao ter uma certa pessoa a frente
naoFrente(NomePessoa1, NomePessoa2, OcupacaoMesa):-
    \+frente(NomePessoa1, NomePessoa2, OcupacaoMesa).

auxiliar_das_retricoes([],_):-!.
auxiliar_das_retricoes([Primeira_Restricao | Resto_ListaRestricoes],OcupacaoMesa):-
    call(Primeira_Restricao, OcupacaoMesa), %chama as restricoes a considerar para a mesa e devolve uma solucao tendo isso em conta
    auxiliar_das_retricoes(Resto_ListaRestricoes, OcupacaoMesa).

ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa):-
    permutation(ListaPessoas, [A, B, C, D, E, F, G, H]), %faz as permutacoes da pessoas da lista de Pessoas nas posicoes de A a H
    OcupacaoMesa = [[A,B,C], [D,E], [F,G,H]], %definicao da mesa
    auxiliar_das_retricoes(ListaRestricoes, OcupacaoMesa). %utiliza a auxiliar para aplicar as restricoes todas 