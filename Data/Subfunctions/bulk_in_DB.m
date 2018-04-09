function bulk_in_DB(DB_PathNameType,OpSer_suffix,Txt_Path)
% bulk_in_DB Read in OpSer and OpSerVal txt files into Access DB
%
%       DB_PathNameType   (Required) - Exakt full name and path of the DB
%       OpSer_suffix      (Required) - Variable name end (suffix) of txt
%                                      file that will be read in 
%       Txt_Path          (Required) - Path of the txt file

%   Author(s): J. Greiner
%              R. Brandalik

% Matlab connection with the Access DB of the Sincal model 
try
    % Create a local OLE Automation server "svr" for starting the Access process
    srv = actxserver('ADODB.connection');
    % Define the Provider
    provider = 'Microsoft.ACE.OLEDB.12.0';
    % Open the connection with the Access Database
    srv.Open(['Provider=' provider ';Data Source=' DB_PathNameType]);
    
    % transaction in the open DB
    % Begin a new transaction in the open DB connection
    invoke(srv,'BeginTrans'); 

    % SQL-Command for reading in the OpSer txt file
    SQL_in = ['INSERT INTO OpSer SELECT * ',...   
    ' FROM [Text;DATABASE=',Txt_Path,'].[OpSer',OpSer_suffix,'.txt]'];
    invoke(srv,'Execute',SQL_in);
    % QL-Command for reading in the OpSerVal txt file
    SQL_in = ['INSERT INTO OpSerVal SELECT * ',...   
    ' FROM [Text;DATABASE=',Txt_Path,'].[OpSerVal',OpSer_suffix,'.txt]'];
    invoke(srv,'Execute',SQL_in);

    % Save all changes
    invoke(srv,'CommitTrans');
    % Close the connection
    invoke(srv,'Close');
    delete(srv);
    clear srv;
    fprintf('Loading data in Sincal %s database successful.\n',DB_PathNameType);
catch
    fprintf('\nSome error occure in %s.\n',DB_PathNameType);
%     bulk_in_DB(DB_PathNameType,OpSer_suffix,Txt_Path);
end
end
