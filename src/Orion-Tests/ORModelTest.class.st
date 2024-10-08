Class {
	#name : 'ORModelTest',
	#superclass : 'ORTest',
	#category : 'Orion-Tests-Core',
	#package : 'Orion-Tests',
	#tag : 'Core'
}

{ #category : 'tests' }
ORModelTest >> testBasename [

	self assert: model basename equals: 'theModel'.
	
	model name: 'theModel_v2'.
	self assert: model basename equals: 'theModel'.
]

{ #category : 'tests' }
ORModelTest >> testBeForOrion [

	model beForOrion.

	self assert: (model allWithType: FamixStPackage) size equals: 2.
	self assert: (model allWithType: FamixStClass) size equals: 6.
	self assert: (model allWithType: FamixStMethod) size equals: 4.
	self assert: (model allWithType: FamixStInheritance) size equals: 5.
	self assert: (model allWithType: FamixStInvocation) size equals: 4.
	self assert: (model allWithType: FamixStReference) size equals: 4.

	self assert: model entityStorage class equals: ORStorage.
	self assert: model entityStorage size equals: 25.

	self assert: model childrenVersions isEmpty.
]

{ #category : 'tests' }
ORModelTest >> testEnsureOrionEntityCreatesNewVersion [
	| class1 class2 model2 |

	model beForOrion.
	model2 := model makeNewVersion.

	class1 := model allClasses anyOne.
	class2 := model2 ensureOrionEntity: class1.

	self deny: class1 identicalTo: class2.
	self assert: class1 name equals: class2 name.
	self assert: class1 parentPackage equals: class2 parentPackage.
	self assertCollection: class1 attributes hasSameElements: class2 attributes.
	self assertCollection: class1 methods hasSameElements: class2 methods.
]

{ #category : 'tests' }
ORModelTest >> testEnsureOrionEntityDoesNotDuplicate [
	| class1 class2 model2 |

	model beForOrion.
	model2 := model makeNewVersion.

	self assert: model allClasses size equals: model2 allClasses size.

	class1 := model allClasses anyOne.
	class2 := model2 ensureOrionEntity: class1.

	self deny: class1 identicalTo: class2.
	self assert: class2 identicalTo: (model2 ensureOrionEntity: class1).
	self assert: class2 identicalTo: (model2 ensureOrionEntity: class2).

]

{ #category : 'tests' }
ORModelTest >> testEnsureOrionEntityDoesNotIncreaseEntitySize [
	| model2 |

	model beForOrion.
	model2 := model makeNewVersion.

	self assert: model2 allClasses size equals: model allClasses size.

	model2 ensureOrionEntity: (model allClasses anyOne).

	self assert: model2 allClasses size equals: model allClasses size.

]

{ #category : 'tests' }
ORModelTest >> testEntitiesCopiedInChildVersion [

	| v2 |
	model beForOrion.
	v2 := model makeNewVersion.

	self assert: v2 entities size equals: model entities size.
	self deny: model entities size equals: 0
]

{ #category : 'tests' }
ORModelTest >> testIsFirstVersion [
	| v2 |
	model beForOrion.
	self assert: model isFirstVersion.

	v2 := model makeNewVersion name: 'v2'.
	self assert: model isFirstVersion.
	self deny: v2 isFirstVersion.
]

{ #category : 'tests' }
ORModelTest >> testIsLastVersion [
	| v2 |
	model beForOrion.
	self assert: model isLastVersion.

	v2 := model makeNewVersion name: 'v2'.
	self deny: model isLastVersion.
	self assert: v2 isLastVersion.
]

{ #category : 'tests' }
ORModelTest >> testMakeNewVersion [
	| v2 |
	model beForOrion.
	self assert: model childrenVersions size equals: 0.

	v2 := model makeNewVersion name: 'v2'.
	self assert: model childrenVersions size equals: 1.
	self assert: model childrenVersions anyOne equals: v2.
	self assert: v2 parentVersion equals: model.
]

{ #category : 'tests' }
ORModelTest >> testMakeNewVersionEntities [

	| ent |
	ent := model entities detect: [ :e | e name = 'Class1' ].
	self assert: ent mooseModel equals: model.
	self assert: ent orionModel equals: model.

	model beForOrion.
	model makeNewVersion name: 'v2'.

	self assert: ent mooseModel equals: model.
	self assert: ent orionModel equals: model.
]

{ #category : 'tests' }
ORModelTest >> testMakeNewVersionName [

	| v2 |
	model beForOrion.
	v2 := model makeNewVersion.
	self assert: model basename equals: v2 basename.
	self deny: model name equals: v2 name.
]

{ #category : 'tests' }
ORModelTest >> testModelContainsOrion [

	| ent v2 |
	ent := model entities detect: [ :e | e name = 'Class1' ].

	model beForOrion.
	self assert: (model containsOrion: ent).

	v2 := model makeNewVersion name: 'v2'.

	self assert: (model containsOrion: ent).
	self deny: (v2 containsOrion: ent).
]

{ #category : 'tests' }
ORModelTest >> testOrionCopy [

	| class1 class2 |

	class1 := model allClasses anyOne.
	class2 := class1 orionCopy.

	self deny: class1 identicalTo: class2.
	self assert: class1 name equals: class2 name.
	self assert: class1 parentPackage equals: class2 parentPackage.
	self assertCollection: class1 attributes hasSameElements: class2 attributes.
	self assertCollection: class1 methods hasSameElements: class2 methods.
]
