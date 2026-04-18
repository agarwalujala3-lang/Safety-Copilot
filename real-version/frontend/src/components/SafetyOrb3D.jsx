import { Canvas, useFrame } from "@react-three/fiber";
import { Float, MeshDistortMaterial, OrbitControls, Sphere, Torus } from "@react-three/drei";
import { useRef } from "react";

function AnimatedCore() {
  const torusRef = useRef(null);

  useFrame((state) => {
    if (!torusRef.current) {
      return;
    }
    torusRef.current.rotation.x = state.clock.elapsedTime * 0.2;
    torusRef.current.rotation.y = state.clock.elapsedTime * 0.35;
  });

  return (
    <>
      <ambientLight intensity={0.9} />
      <directionalLight position={[2, 3, 4]} intensity={1.2} />
      <Float speed={2} rotationIntensity={0.4} floatIntensity={1.2}>
        <Sphere args={[1.1, 64, 64]}>
          <MeshDistortMaterial
            color="#14c8a8"
            roughness={0.1}
            metalness={0.8}
            distort={0.28}
            speed={2}
          />
        </Sphere>
      </Float>
      <Torus ref={torusRef} args={[1.75, 0.08, 24, 120]}>
        <meshStandardMaterial color="#ff8a48" metalness={1} roughness={0.2} />
      </Torus>
    </>
  );
}

export default function SafetyOrb3D() {
  return (
    <div className="orb-wrapper">
      <Canvas camera={{ position: [0, 0, 5.5], fov: 45 }}>
        <AnimatedCore />
        <OrbitControls enableZoom={false} enablePan={false} autoRotate autoRotateSpeed={0.8} />
      </Canvas>
    </div>
  );
}
