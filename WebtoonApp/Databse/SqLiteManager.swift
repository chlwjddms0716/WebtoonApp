

import Foundation
import SQLite3

class SqLiteManager {
    
    static let shared = SqLiteManager()
    
    // db를 가리키는 포인터
    var db : OpaquePointer?
    let databaseName = "mydb.sqlite"
    let tableName = "history_tbl"
    
    init() {
        self.db = createDB()
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - DB 생성
    private func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        do {
            let dbPath: String = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent(databaseName).path
            
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Successfully created DB. Path: \(dbPath)")
                return db
            }
        } catch {
            print("Error while creating Database -\(error.localizedDescription)")
        }
        return nil
    }
    
    // MARK: - Table 생성
    func createTable(){
        let query = """
             CREATE TABLE IF NOT EXISTS history_tbl(
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             keyword TEXT NOT NULL,
             time INT NOT NULL
             );
             """
        
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query.cString(using: .utf8), -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Creating table has been succesfully done.")
            }
            else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("\nsqlte3_step failure while creating table: \(errorMessage)")
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(self.db))
            print("\nsqlite3_prepare failure while creating table: \(errorMessage)")
        }
        
        sqlite3_finalize(statement) // 메모리에서 sqlite3 할당 해제.
    }
    
    
    // MARK: - 데이터 추가
    func insertData(keyword: String) {
        
        if checkData(keyword) {
            updateData(keyword)
        }
        else {
            let insertQuery = "insert into \(tableName) (id,  keyword, time) values (?, ?, ?);"
            var statement: OpaquePointer? = nil
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            if sqlite3_prepare_v2(self.db, insertQuery, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 2, keyword.cString(using: .utf8), -1, SQLITE_TRANSIENT)
                sqlite3_bind_int(statement, 3, Int32(Date().timeIntervalSince1970.rounded()))
                
            }
            else {
                print("sqlite binding failure")
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("sqlite insertion success")
            }
            else {
                print("sqlite step failure")
            }
        }
    }
    
    // MARK: - 중복 데이터 있는지 확인
    private func checkData(_ keyword: String) -> Bool {
        let query: String = "select * from \(tableName) where keyword == '\(keyword)';"
        var statement: OpaquePointer? = nil
        var result: Bool = false
        
        if sqlite3_prepare(self.db, query, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("error while prepare: \(errorMessage)")
            return result
        }
        if sqlite3_step(statement) == SQLITE_ROW {
            result = true
        }
        sqlite3_finalize(statement)
        
        return result
    }
    
    // MARK: - 검색어 시간만 업데이트
    private func updateData(_ keyword: String) {
        var statement: OpaquePointer?
        
        let queryString = "UPDATE \(tableName) SET time = \(Int32(Date().timeIntervalSince1970.rounded())) WHERE keyword == '\(keyword)'"
        
        if sqlite3_prepare(db, queryString, -1, &statement, nil) != SQLITE_OK {
            onSQLErrorPrintErrorMessage(db)
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            onSQLErrorPrintErrorMessage(db)
            return
        }
    }
    
    // MARK: - 검색기록 읽어오기
    func readData() -> [SearchTerm] {
        let query: String = "select * from \(tableName);"
        var statement: OpaquePointer? = nil
        
        var result: [SearchTerm] = []
        
        if sqlite3_prepare(self.db, query, -1, &statement, nil) != SQLITE_OK {
            let errorMessage = String(cString: sqlite3_errmsg(db)!)
            print("error while prepare: \(errorMessage)")
            return result
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            
            let id = sqlite3_column_int(statement, 0) // 결과의 0번째 테이블 값
            let keyword = String(cString: sqlite3_column_text(statement, 1)) // 결과의 1번째 테이블 값.
            let time = sqlite3_column_int(statement, 2) // 결과의 2번째 테이블 값.
            
            result.append(SearchTerm(id: Int(id), keyword: keyword, timestamp: Int(time)))
        }
        sqlite3_finalize(statement)
        
        // 최근 검색된 순서대로 정렬
        let sortedSearchHistory = result.sorted(by: { term1, term2 in
            return term1.timestamp > term2.timestamp
        })
        
        return sortedSearchHistory
    }
    
    // MARK: - 검색어 삭제
    func deleteData(id: Int) {
        let queryString = "DELETE FROM \(tableName) WHERE id == \(id)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &statement, nil) != SQLITE_OK {
            onSQLErrorPrintErrorMessage(db)
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            onSQLErrorPrintErrorMessage(db)
            return
        }
    }
    
    // MARK: - Table 삭제
    func deleteTable() {
        let queryString = "DROP TABLE \(tableName)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &statement, nil) != SQLITE_OK {
            onSQLErrorPrintErrorMessage(db)
            return
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            onSQLErrorPrintErrorMessage(db)
            return
        }
    }
    
    private func onSQLErrorPrintErrorMessage(_ db: OpaquePointer?) {
        let errorMessage = String(cString: sqlite3_errmsg(db))
        print("Error preparing update: \(errorMessage)")
        return
    }
}
