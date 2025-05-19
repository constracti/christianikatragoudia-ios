//
//  SongTitle.swift
//  Christianika Tragoudia iOS
//
//  Created by Konstantinos Raktivan on 03-05-2025.
//


class SongTitle: Identifiable, Comparable {
    
    let id: Int
    let title: String
    let excerpt: String
    
    init(id: Int, title: String, excerpt: String) {
        self.id = id
        self.title = title
        if #available(iOS 16.0, *) {
            self.excerpt = String(excerpt.split(separator: /\r\n|\r|\n/).first!)
        } else {
            self.excerpt = excerpt
                .replacingOccurrences(of: "\r\n|\r|\n", with: "\n", options: .regularExpression)
                .components(separatedBy: "\n")
                .first!
        }
    }
    
    convenience init(songMatch: SongMatch) {
        self.init(id: songMatch.id, title: songMatch.title, excerpt: songMatch.excerpt)
    }
    
    static func <=> (lhs: SongTitle, rhs: SongTitle) -> Spaceship? {
        (lhs.title <=> rhs.title) ?? (lhs.excerpt <=> rhs.excerpt) ?? (lhs.id <=> rhs.id)
    }
    
    static func < (lhs: SongTitle, rhs: SongTitle) -> Bool {
        (lhs <=> rhs) == .asc
    }
    
    static func == (lhs: SongTitle, rhs: SongTitle) -> Bool {
        (lhs <=> rhs) == nil
    }

    static func getAll(db: TheDatabase) -> Array<SongTitle> {
        let sql = """
            SELECT `song`.`id`, `song`.`title`, `song`.`excerpt`
            FROM `song`
            JOIN `chord` ON `chord`.`parent` = `song`.`id`
            """
        var list = Array<SongTitle>()
        let stmt = Statement(db: db, sql: sql)
        while stmt.step() == .ROW {
            list.append(SongTitle(
                id: stmt.readInt(index: 0),
                title: stmt.readString(index: 1),
                excerpt: stmt.readString(index: 2),
            ))
        }
        return list.sorted()
    }
}
