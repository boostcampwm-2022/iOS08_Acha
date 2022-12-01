//
//  CommunityRepository.swift
//  Acha
//
//  Created by hong on 2022/12/02.
//

import Foundation
import RxSwift
import RxRelay

protocol CommunityRepository {
    
    /// 모든 포스트를  가져 오는 메서드
    func getAllPost() -> Single<[Post]>
    
    /// 특정한 포스트를 가져 오는 메서드
    func getPost(id: Int) -> Single<Post>
    
    /// 특정한 포스트의  커멘트들을 가져오는 메서드
    func getPostComments(id: Int) -> Single<[Comment]>
    
    /// 포스트의 특정 커멘트를 가져오는 메서드 ( 혹시 몰라서 옵셔널 처리 함)
    func getPostComment(id: Int) -> Single<Comment?>
    
    /// 포스트 만드는 메서드
    func makePost(data: Post)
    
    /// 커멘트 만드는 메서드
    func makeComment(data: Comment)
    
    /// 포스트 지우는 메서드
    func deletePost(id: Int)
    
    /// 커멘트 지우는 메서드
    func deleteComment(data: Comment)
    
    /// 포스트를 변경하는 메서드 
    func changePost(data: Post)
    
    /// 댓글을 변경하는 메서드
    func changeComment(data: Comment)
}
