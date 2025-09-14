package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

// UploadController 文件上传控制器
type UploadController struct{}

// UploadFile 处理文件上传
// @Summary      文件上传
// @Description  上传单个文件到服务器
// @Tags         文件
// @Accept       multipart/form-data
// @Produce      json
// @Param        file  formData  file  true  "上传的文件"
// @Success      200   {object}  map[string]interface{}  "上传成功"
// @Failure      400   {object}  map[string]interface{}  "请求错误"
// @Failure      500   {object}  map[string]interface{}  "服务器错误"
// @Router       /api/v1/upload [post]
func (uc *UploadController) UploadFile(c *gin.Context) {
	file, err := c.FormFile("file")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": fmt.Sprintf("获取文件失败: %s", err.Error())})
		return
	}

	// 检查文件大小 (例如，限制为 5MB)
	if file.Size > 5*1024*1024 {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "文件大小不能超过 5MB"})
		return
	}

	// 检查文件类型 (例如，只允许图片)
	ext := filepath.Ext(file.Filename)
	if ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif" && ext != ".webp" {
		c.JSON(http.StatusBadRequest, gin.H{"code": 400, "message": "只允许上传 JPG, JPEG, PNG, GIF, WEBP 格式的图片"})
		return
	}

	// Determine the upload subdirectory based on the 'type' query parameter
	fileType := c.DefaultQuery("type", "others") // Default to 'others' if no type is provided

	// Define allowed types and their corresponding subdirectories
	allowedTypes := map[string]string{
		"avatar":   "avatars",
		"dish":     "dishes",
		"logo":     "logos",
		"setmeal":  "setmeals",
		"others":   "others", // Generic folder for other uploads
	}

	subDir, ok := allowedTypes[fileType]
	if !ok {
		subDir = "others" // Fallback to 'others' if type is not recognized
	}

	baseUploadDir := "./backend/uploads" // Base upload directory
	targetDir := filepath.Join(baseUploadDir, subDir)

	// Create the target directory if it doesn't exist
	if err := os.MkdirAll(targetDir, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": fmt.Sprintf("创建上传目录失败: %s", err.Error())})
		return
	}

	// Generate a unique filename using timestamp and a random number
	newFileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)

	// Construct the full path to save the file
	savePath := filepath.Join(targetDir, newFileName)

	// Save the file
	if err := c.SaveUploadedFile(file, savePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": fmt.Sprintf("保存文件失败: %s", err.Error())})
		return
	}

	// Return the URL path for the frontend to access (relative to /uploads)
	fileURL := "/uploads/" + subDir + "/" + newFileName // This is the URL path including subdirectory
	c.JSON(http.StatusOK, gin.H{"code": 200, "message": "上传成功", "data": gin.H{"url": fileURL}})
}