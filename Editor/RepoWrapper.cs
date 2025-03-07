using System.IO;
using Cysharp.Threading.Tasks;
using Nomnom.UnityProjectPatcher.Editor;
using Nomnom.UnityProjectPatcher.Editor.Steps;
using UnityEditor;
using UnityEngine;

namespace Kesomannen.RepoProjectPatcher.Editor {
    [UPPatcher("com.kesomannen.unity-repo-project-patcher")]
    public static class RepoWrapper {
        public static void GetSteps(StepPipeline stepPipeline) {
            stepPipeline.InsertAfter<AssetRipperStep>(new SanitizeFoldersStep());
            stepPipeline.Steps.RemoveAll(step => step is AssetRipperStep);

            stepPipeline.SetInputSystem(InputSystemType.Both);
            stepPipeline.SetGameViewResolution("16:9");
            stepPipeline.OpenSceneAtEnd("Main");
            stepPipeline.InsertLast(new FixES3Step());
        }
    }

    struct SanitizeFoldersStep : IPatcherStep {
        public UniTask<StepResult> Run() {
            var assetsRoot = Path.Combine(
                PatcherUtility.GetUserSettings().AssetRipperExportFolderPath, 
                "ExportedProject", 
                "Assets"
            );
            
            var folders = Directory.GetDirectories(assetsRoot, "*", SearchOption.TopDirectoryOnly);
            foreach (var folder in folders) {
                var folderName = Path.GetFileName(folder);
                if (folderName.Contains(".") || folderName.Contains(" ")) {
                    var newFolderName = folderName.Replace(".", string.Empty).Replace(' ', '_');
                    var folderRoot = Path.GetDirectoryName(folder);
                    Directory.Move(folder, Path.Combine(folderRoot, newFolderName));
                }
            }

            return UniTask.FromResult(StepResult.Success);
        }

        public void OnComplete(bool failed) { }
    }
}