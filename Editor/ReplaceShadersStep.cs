using System.IO;
using Cysharp.Threading.Tasks;
using Nomnom.UnityProjectPatcher.Editor.Steps;
using UnityEditor;
using UnityEngine;

namespace Kesomannen.RepoProjectPatcher.Editor {
    // replace some of the AssetRipper dummy shaders with hand coded ones
    public struct ReplaceShadersStep : IPatcherStep {
        [MenuItem("Tools/R.E.P.O. Project Patcher/Replace Shaders")]
        static void MenuItem() {
            ReplaceShaders();
        }

        static void ReplaceShaders() {
            var gameShadersFolder = "Assets/REPO/Game/Shaders";
            var customShadersFolder = $"Packages/{Constants.PackageName}/Shaders";
            
            var guids = AssetDatabase.FindAssets("t:Shader", new[] { customShadersFolder });
            foreach (var guid in guids) {
                var fromPath = AssetDatabase.GUIDToAssetPath(guid);
                var toPath = fromPath.Replace(customShadersFolder, gameShadersFolder);
                
                var fromFullPath = Path.GetFullPath(fromPath);
                var toFullPath = Path.GetFullPath(toPath);
                
                Debug.Log($"Replacing shader at {toPath} with {fromPath}");
                File.Copy(fromFullPath, toFullPath, true);
            }
        
            AssetDatabase.Refresh();
        }
        
        public UniTask<StepResult> Run() {
            ReplaceShaders();
            return UniTask.FromResult(StepResult.Success);
        }

        public void OnComplete(bool failed) { }
    }
}