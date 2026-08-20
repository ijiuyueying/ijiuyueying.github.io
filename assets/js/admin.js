/*
 * 九月影知识库管理后台脚本
 * 第二阶段：分类删除检查 + 操作日志框架
 *
 * 当前能力：
 * 1. 获取选择分类
 * 2. 删除前风险检查
 * 3. 生成操作日志数据
 * 4. 为后续 GitHub API 接入预留
 */

(function () {
    'use strict';

    function getSelectedCategories() {
        const checked = document.querySelectorAll(
            'input[name="category"]:checked'
        );

        return Array.from(checked).map(item => item.value);
    }

    // 模拟资源检查
    // 后续接入 Jekyll 文章和图片索引
    function checkCategoryUsage(categories) {
        return {
            categories,
            articles: '待扫描',
            images: '待扫描',
            references: '待扫描'
        };
    }

    function beforeDelete() {
        const categories = getSelectedCategories();

        if (categories.length === 0) {
            alert('请先选择需要处理的分类');
            return;
        }

        const checkResult = checkCategoryUsage(categories);

        const message =
            '删除风险检查：\n\n' +
            '分类：\n' + categories.join('\n') +
            '\n\n关联文章：' + checkResult.articles +
            '\n关联图片：' + checkResult.images +
            '\n引用关系：' + checkResult.references +
            '\n\n下一阶段接入真实扫描。';

        alert(message);
    }

    function createOperationLog(action, target, result) {
        return {
            time: new Date().toISOString(),
            action,
            target,
            result
        };
    }

    window.adminCategory = {
        getSelectedCategories,
        beforeDelete,
        createOperationLog
    };
})();
