importHScriptClasses("scripts/classes/ChromaKeyShader.hx");
shader = new ChromaKeyShader("characters/fake png shit");
anim.onFrame.add((_, _, _) -> shader.updateSprite(this));
shader.updateSprite(this);