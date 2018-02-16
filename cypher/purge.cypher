MATCH (g:GauntletAnalysis)-->(gt:GauntletTeam)
DETACH DELETE gt;
MATCH (g:GauntletAnalysis)-->(gc:GauntletCrew)
DETACH DELETE gc;
MATCH (g:GauntletAnalysis)
DETACH DELETE g;

