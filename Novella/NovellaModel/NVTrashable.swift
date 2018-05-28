//
//  NVTrashable
//  NovellaModel
//
//  Created by Daniel Green on 28/05/2018.
//  Copyright © 2018 Daniel Green. All rights reserved.
//

public protocol NVTrashable: NVIdentifiable {
	func inTrash() -> Bool
	func trash()
	func untrash()
}
