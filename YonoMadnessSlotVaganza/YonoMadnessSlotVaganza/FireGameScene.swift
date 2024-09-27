//
//  FireGameScene.swift
//  Luck Slot Lyric Lush
//
//  Created by Madness Slot Vaganza on 25/07/24.
//


import UIKit
import SceneKit

enum YonoMadnessGameSceneDelegateCollisionCategory: Int {
    case none = 0
    case bullet = 1
    case enemy = 2
    case tank = 3
}

class YonoMadnessGameSceneDelegateGameScene: SCNScene, SCNPhysicsContactDelegate {
    
    var tankNode: SCNNode!
    var enemies: [SCNNode] = []
    
    weak var delegate: YonoMadnessGameSceneDelegate?
    var smokeParticleSystem: SCNParticleSystem?
    
    //MARK: - init
    
    override init() {
        super.init()
        setupScene()
        setupTank()
        startEnemySpawnTimer()
        physicsWorld.contactDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - setup scene
    
    func setupScene() {
        
        let cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 10, z: 15)
        cameraNode.look(at: SCNVector3Zero)
        rootNode.addChildNode(cameraNode)
        
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        rootNode.addChildNode(ambientLightNode)
        
        // Create the floor
        let floor = SCNFloor()
        let floorNode = SCNNode(geometry: floor)
        
        let grassMaterial = SCNMaterial()
        
        grassMaterial.diffuse.contents = UIImage(named: "grassTexture")
        
        grassMaterial.diffuse.wrapS = .repeat
        grassMaterial.diffuse.wrapT = .repeat
        
        grassMaterial.specular.contents = nil
        grassMaterial.shininess = 0.0
        grassMaterial.diffuse.wrapS = .repeat
        grassMaterial.diffuse.wrapT = .repeat
        
        floor.materials = [grassMaterial]
        
        // Add the floor node to the scene
        rootNode.addChildNode(floorNode)
        
        
        // Set gravity to zero to prevent downward movement
        physicsWorld.gravity = SCNVector3.init(x: 0, y: 0, z: 0)
    }
    
    //MARK: - setup tank
    
    func setupTank() {
        
        guard let modelScene = SCNScene(named: "plane.obj") else {
            print("Unable to load 3D model.")
            return
        }
        
        // Find the root node of the 3D model
        let modelNode = modelScene.rootNode.childNodes.first ?? SCNNode()
        
        // Set up model node position
        modelNode.position = SCNVector3(x: 0, y: 0.28, z: 0) // Adjust the position as necessary
        
        // Rotate the model node 90 degrees around the X-axis
        modelNode.eulerAngles.x = -Float.pi / 2 // 90 degrees in radians
        
        // Apply a gray color to the model's material
        let grayMaterial = SCNMaterial()
        grayMaterial.diffuse.contents = UIColor.gray
        modelNode.geometry?.materials = [grayMaterial] // Apply the gray material
        
        // Add physics body to the model node if needed
        modelNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: modelNode, options: nil))
        modelNode.physicsBody?.categoryBitMask = YonoMadnessGameSceneDelegateCollisionCategory.tank.rawValue
        modelNode.physicsBody?.contactTestBitMask = YonoMadnessGameSceneDelegateCollisionCategory.bullet.rawValue
        modelNode.physicsBody?.collisionBitMask = YonoMadnessGameSceneDelegateCollisionCategory.tank.rawValue
        
        // Adjust the model's scale
        modelNode.scale = SCNVector3(0.01, 0.01, 0.01) // Adjust as needed
        
        // Replace the old tankNode with the new model
        tankNode = modelNode
        rootNode.addChildNode(tankNode)
        
        // Add smoke effect to the back of the plane
        addSmokeEffect(to: modelNode)
        updateSmokeBasedOnHealth(health: 100) // Set initial health
    }

    // Function to add smoke with proper exhaust direction
    func addSmokeEffect(to node: SCNNode) {
        let smokeParticleSystem = createSmokeParticleSystem()
        
        // Create a node for the smoke and attach it to the plane
        let smokeNode = SCNNode()
        smokeNode.position = SCNVector3(x: 0, y: 0, z: -1.5) // Adjust position behind the plane
        
        smokeNode.addParticleSystem(smokeParticleSystem)
        
        // Add smoke node as a child of the plane node
        node.addChildNode(smokeNode)
    }

    // Function to create a smoke particle system
    func createSmokeParticleSystem() -> SCNParticleSystem {
        
        let particleSystem = SCNParticleSystem()
        particleSystem.particleLifeSpan = 1.0 // How long the particles last
        particleSystem.birthRate = 100 // High birth rate for dense smoke
        particleSystem.emissionDuration = 1.0
        particleSystem.particleSize = 0.05 // Larger particles for thicker smoke
        particleSystem.particleVelocity = 1.0
        particleSystem.particleColor = UIColor.red // Dark smoke
        particleSystem.particleColorVariation = SCNVector4(0.2, 0.2, 0.2, 0.0)
        particleSystem.emissionDuration = 0.1
        particleSystem.particleVelocity = -100.0
        
        return particleSystem
    }

    // Function to adjust smoke intensity based on health
    func updateSmokeBasedOnHealth(health: Double) {
        
        guard let smokeParticleSystem = smokeParticleSystem else { return }
        
        let smokeIntensity = max(1.0, (100 - health) / 10)
        
        smokeParticleSystem.birthRate = 500 * smokeIntensity
        smokeParticleSystem.particleSize = 0.05 + (0.1 * (1.0 - health / 100.0))
        smokeParticleSystem.particleColor = UIColor(white: 0.1 + (0.9 * (1.0 - health / 100.0)), alpha: 1.0)
    }

    
    
    //MARK: - enemy
    
    func startEnemySpawnTimer() {
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(spawnEnemy), userInfo: nil, repeats: true)
    }
    
    @objc func spawnEnemy() {
        let enemyNode = createEnemy()
        enemies.append(enemyNode)
        rootNode.addChildNode(enemyNode)
        
        // Start enemy movement
        moveEnemy(enemyNode)
    }
    
    //MARK: - bullet
    
    func createBullet() -> SCNNode {
        // Create the bullet geometry as a sphere
        let bulletGeometry = SCNSphere(radius: 0.1)
        
        // Create the material for the bullet
        let bulletMaterial = SCNMaterial()
        bulletMaterial.diffuse.contents = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // Base color
        bulletMaterial.emission.contents = UIColor.yellow // Emission for the glowing effect (change color as desired)
        
        // Apply the material to the bullet geometry
        bulletGeometry.firstMaterial = bulletMaterial
        
        // Create the bullet node
        let bulletNode = SCNNode(geometry: bulletGeometry)
        bulletNode.position = SCNVector3(x: tankNode.position.x, y: tankNode.position.y + 0.37, z: tankNode.position.z) // Adjust position
        
        // Add a physics body to the bullet
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        bulletNode.physicsBody?.categoryBitMask = YonoMadnessGameSceneDelegateCollisionCategory.bullet.rawValue
        bulletNode.physicsBody?.contactTestBitMask = YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue
        bulletNode.physicsBody?.collisionBitMask = YonoMadnessGameSceneDelegateCollisionCategory.none.rawValue
        
        // Optional: Add a light node to enhance the glowing effect
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni // Omni-directional light
        light.color = UIColor.yellow // Light color matches the emission
        light.intensity = 500 // Adjust the intensity of the glow
        
        lightNode.light = light
        lightNode.position = SCNVector3(0, 0, 0) // Light is centered on the bullet
        bulletNode.addChildNode(lightNode)
        
        return bulletNode
    }
    
    //MARK: - diamond
    
    func createEnemy() -> SCNNode {
        
        let bodyGeometry = SCNSphere(radius: 1.0)
        
        // Create a material and set random colors for both diffuse and emission
        let randomColor = generateRandomColor()
        let randomEmissionColor = generateRandomColor() // Optional: Different color for emission
        
        bodyGeometry.firstMaterial?.diffuse.contents = randomColor
        bodyGeometry.firstMaterial?.emission.contents = randomEmissionColor
        
        let shipNode = SCNNode(geometry: bodyGeometry)
        
        // Set random position
        let randomX = Float.random(in: -50...50)
        let randomZ = Float.random(in: -50...50)
        shipNode.position = SCNVector3(randomX, 0.5, randomZ)
        
        // Add physics body
        shipNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        shipNode.physicsBody?.categoryBitMask = YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue
        shipNode.physicsBody?.contactTestBitMask = YonoMadnessGameSceneDelegateCollisionCategory.bullet.rawValue
        shipNode.physicsBody?.collisionBitMask = YonoMadnessGameSceneDelegateCollisionCategory.none.rawValue
        shipNode.physicsBody?.isAffectedByGravity = false
        
        addAlienShipDetails(to: shipNode)
        
        return shipNode
    }

    func generateRandomColor() -> UIColor {
        let red = CGFloat.random(in: 0...1)
        let green = CGFloat.random(in: 0...1)
        let blue = CGFloat.random(in: 0...1)
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    
    func addAlienShipDetails(to shipNode: SCNNode) {
        
        let wingGeometry = SCNBox(width: 0.1, height: 0.02, length: 1.0, chamferRadius: 0)
        wingGeometry.firstMaterial?.diffuse.contents = UIColor.gray
        let wingNodeLeft = SCNNode(geometry: wingGeometry)
        wingNodeLeft.position = SCNVector3(-1.0, 0, 0)
        shipNode.addChildNode(wingNodeLeft)
        
        let wingNodeRight = SCNNode(geometry: wingGeometry)
        wingNodeRight.position = SCNVector3(1.0, 0, 0)
        shipNode.addChildNode(wingNodeRight)
        
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .omni
        light.color = UIColor.cyan
        light.intensity = 1000
        lightNode.light = light
        lightNode.position = SCNVector3(0, 1.2, 0)
        shipNode.addChildNode(lightNode)
    }
    
    
    
    func moveEnemy(_ enemyNode: SCNNode) {
        guard let tankNode = tankNode else { return }
        
        // Calculate direction vector from enemy to tank
        let direction = SCNVector3(
            tankNode.position.x - enemyNode.position.x,
            tankNode.position.y - enemyNode.position.y,
            tankNode.position.z - enemyNode.position.z
        )
        
        // Normalize direction vector
        let length = sqrt(direction.x * direction.x + direction.y * direction.y + direction.z * direction.z)
        let normalizedDirection = SCNVector3(
            direction.x / length,
            direction.y / length,
            direction.z / length
        )
        
        // Randomize the speed of each enemy for more variety
        let speed = Float.random(in: 0.05...0.2)
        
        // Create movement action based on direction and speed
        let moveAction = SCNAction.move(by: normalizedDirection * speed, duration: 0.1)
        let repeatAction = SCNAction.repeatForever(moveAction)
        
        enemyNode.runAction(repeatAction)
    }

    //MARK: - fire bullete
    
    func fireBullet() {
        let bulletNode = createBullet()
        rootNode.addChildNode(bulletNode)
        
        let bulletDirection = SCNVector3(
            sin(tankNode.eulerAngles.y) * 50,
            0,
            cos(tankNode.eulerAngles.y) * 50
        )
        
        let moveBulletAction = SCNAction.move(by: bulletDirection, duration: 3.0)
        
        // Automatically remove the bullet after it has traveled its path or collides
        bulletNode.runAction(moveBulletAction) {
            bulletNode.removeFromParentNode()
        }
    }

    
    // MARK: - collition
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let (nodeA, nodeB) = (contact.nodeA, contact.nodeB)
        
        if (nodeA.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.tank.rawValue &&
            nodeB.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue){
            
            nodeB.removeFromParentNode()
            
            delegate?.YonoMadnesshealthSet(-1)
            
        }else if (nodeA.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue &&
                  nodeB.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.tank.rawValue){
            
            nodeA.removeFromParentNode()
            
            delegate?.YonoMadnesshealthSet(-1)
            
        }
        
        if (nodeA.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.bullet.rawValue &&
            nodeB.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue) ||
            (nodeB.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.bullet.rawValue &&
             nodeA.physicsBody?.categoryBitMask == YonoMadnessGameSceneDelegateCollisionCategory.enemy.rawValue) {
            
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            
            delegate?.YonoMadnessdidAddScore()
            
        }
    }
    
    // MARK: - Tank Control
    
    func rotateTank(to angle: Float) {
        tankNode.eulerAngles.y = angle
    }
    
}

extension SCNVector3 {
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
}

