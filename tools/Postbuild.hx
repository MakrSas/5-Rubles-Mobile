package tools;

import haxe.Log;
import sys.FileSystem;
import sys.io.File;
import tools.Prebuild;

using StringTools;

class Postbuild
{
	static inline final ROUND_TO = 1000.0;

	static function main():Void
	{
		linkMacAssets();

		final end:Float = Sys.time();
		if (FileSystem.exists(Prebuild.BUILD_TIME_FILE))
		{
			final file = File.read(Prebuild.BUILD_TIME_FILE);
			final start:Float = file.readDouble();

			final completeTime = Math.round((end - start) * ROUND_TO) / ROUND_TO;
			Log.trace('Build complete in $completeTime seconds!', null);

			// cleanup
			file.close();
			FileSystem.deleteFile(Prebuild.BUILD_TIME_FILE);
		}
		else
		{
			Log.trace("Build complete!", null);
		}
	}

	/**
		With `USE_SYS_ASSETS`, desktop builds read assets from `./assets/` relative to the
		process's working directory. On mac, the app bundle's binary starts in
		`Contents/Resources/`, not the project root, so `.app` bundles need an `assets` symlink
		inside `Contents/Resources/` pointing back at the project's real `assets/` folder.
	**/
	static function linkMacAssets():Void
	{
		if (Sys.systemName() != "Mac")
			return;

		try
		{
			final projectAssets = FileSystem.absolutePath("assets");
			if (!FileSystem.exists(projectAssets))
				return;

			for (app in findMacApps("export"))
			{
				final resources = '$app/Contents/Resources';
				final link = '$resources/assets';
				if (!FileSystem.exists(resources) || FileSystem.exists(link))
					continue;

				Sys.command("ln", ["-s", projectAssets, link]);
			}
		}
		catch (e) {}
	}

	static function findMacApps(dir:String):Array<String>
	{
		final apps = [];
		if (!FileSystem.exists(dir) || !FileSystem.isDirectory(dir))
			return apps;

		for (entry in FileSystem.readDirectory(dir))
		{
			final path = '$dir/$entry';
			if (!FileSystem.isDirectory(path))
				continue;
			if (entry.endsWith(".app"))
				apps.push(path);
			else
				for (nested in findMacApps(path))
					apps.push(nested);
		}
		return apps;
	}
}