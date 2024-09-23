//#include <iostream>
//#include <fstream>
//#include <string>
//#include <libpq-fe.h>
//#include <uuid/uuid.h>
//
//void executeSQL(const std::string& filename, const std::string& username, const std::string& password, const std::string& schema, const std::string& database) {
//    std::ifstream file(filename);
//    if (!file.is_open()) {
//        std::cerr << "Не удалось открыть файл: " << filename << std::endl;
//        return;
//    }
//
//    std::string content((std::istreambuf_iterator<char>(file)), std::istreambuf_iterator<char>());
//    file.close();
//
//    size_t pos = content.find("public");
//    while (pos != std::string::npos) {
//        content.replace(pos, 6, schema);
//        pos = content.find("public", pos + schema.length());
//    }
//
//    uuid_t uuid;
//    uuid_generate(uuid);
//    char uuid_str[37];
//    uuid_unparse(uuid, uuid_str);
//    std::string temp_filename = "/tmp/" + std::string(uuid_str) + ".sql";
//
//    std::ofstream tmp_file(temp_filename);
//    if (!tmp_file.is_open()) {
//        std::cerr << "Не удалось создать временный файл: " << temp_filename << std::endl;
//        return;
//    }
//    tmp_file << content;
//    tmp_file.close();
//
//    PGconn* conn = PQsetdbLogin("localhost", "5432", nullptr, nullptr, database.c_str(), username.c_str(), password.c_str());
//    if (PQstatus(conn) != CONNECTION_OK) {
//        std::cerr << "Ошибка подключения: " << PQerrorMessage(conn) << std::endl;
//        PQfinish(conn);
//        return;
//    }
//    std::ifstream sql_file(temp_filename);
//    std::string sql_content((std::istreambuf_iterator<char>(sql_file)), std::istreambuf_iterator<char>());
//    sql_file.close();
//
//    PGresult* res = PQexec(conn, sql_content.c_str());
//    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
//        std::cerr << "Ошибка выполнения SQL: " << PQerrorMessage(conn) << std::endl;
//    } else {
//        std::cout << "SQL успешно выполнен." << std::endl;
//    }
//    PQclear(res);
//    PQfinish(conn);
//}
//
//int main(int argc, char* argv[]) {
//    if (argc != 6) {
//        std::cerr << "Использование: " << argv[0] << " <filename> <username> <password> <schema> <database>" << std::endl;
//        return 1;
//    }
//
//    std::string filename = argv[1];
//    std::string username = argv[2];
//    std::string password = argv[3];
//    std::string schema = argv[4];
//    std::string database = argv[5];
//
//    executeSQL(filename, username, password, schema, database);
//
//    return 0;
//}
//
//
