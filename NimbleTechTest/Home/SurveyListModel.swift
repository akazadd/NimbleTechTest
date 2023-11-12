//
//  SurveyListModel.swift
//  NimbleTechTest
//
//  Created by A K Azad on 3/11/23.
//

import Foundation

struct SurveyListModel : Codable {
    let surveyList : [Survey]?
    let meta : Meta?

    enum CodingKeys: String, CodingKey {
        case surveyList = "data"
        case meta = "meta"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        surveyList = try values.decodeIfPresent([Survey].self, forKey: .surveyList)
        meta = try values.decodeIfPresent(Meta.self, forKey: .meta)
    }

}

struct Survey : Codable {
    let id, type : String?
    let attributes : SurveyAttributes?
    let relationships : Relationships?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
        case relationships = "relationships"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        type = try values.decodeIfPresent(String.self, forKey: .type)
        attributes = try values.decodeIfPresent(SurveyAttributes.self, forKey: .attributes)
        relationships = try values.decodeIfPresent(Relationships.self, forKey: .relationships)
    }
}

struct SurveyAttributes : Codable {
    let title, description : String?
    let thank_email_above_threshold, thank_email_below_threshold : String?
    let is_active : Bool?
    let cover_image_url, created_at, active_at, inactive_at, survey_type : String?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
        case thank_email_above_threshold = "thank_email_above_threshold"
        case thank_email_below_threshold = "thank_email_below_threshold"
        case is_active = "is_active"
        case cover_image_url = "cover_image_url"
        case created_at = "created_at"
        case active_at = "active_at"
        case inactive_at = "inactive_at"
        case survey_type = "survey_type"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        thank_email_above_threshold = try values.decodeIfPresent(String.self, forKey: .thank_email_above_threshold)
        thank_email_below_threshold = try values.decodeIfPresent(String.self, forKey: .thank_email_below_threshold)
        is_active = try values.decodeIfPresent(Bool.self, forKey: .is_active)
        cover_image_url = try values.decodeIfPresent(String.self, forKey: .cover_image_url)
        created_at = try values.decodeIfPresent(String.self, forKey: .created_at)
        active_at = try values.decodeIfPresent(String.self, forKey: .active_at)
        inactive_at = try values.decodeIfPresent(String.self, forKey: .inactive_at)
        survey_type = try values.decodeIfPresent(String.self, forKey: .survey_type)
    }

}


// MARK: - Relationships
struct Relationships : Codable {
    let questions : Questions?

    enum CodingKeys: String, CodingKey {
        case questions = "questions"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        questions = try values.decodeIfPresent(Questions.self, forKey: .questions)
    }

}

// MARK: - Questions
struct Questions : Codable {
    let data : [QuestionList]?

    enum CodingKeys: String, CodingKey {
        case data = "data"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decodeIfPresent([QuestionList].self, forKey: .data)
    }
}

// MARK: - QuestionList
struct QuestionList: Codable {
    let id: String
    let type: TypeEnum
}

enum TypeEnum: String, Codable {
    case question = "question"
}

// MARK: - Meta
struct Meta: Codable {
    let page, pages, pageSize, records: Int

    enum CodingKeys: String, CodingKey {
        case page, pages
        case pageSize = "page_size"
        case records
    }
}
