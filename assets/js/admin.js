/*
 * 九月影知识库管理后台脚本
 * 第一阶段：分类管理基础能力
 *
 * 当前只负责：
 * 1. 获取用户选择的分类
 * 2. 删除前检查提示
 * 3. 为后续 GitHub API 接入预留
 */

(function () {
    'use strict';

    function getSelectedCategories() {
        const checked = document.querySelectorAll(
            'input[name="category"]:checked'
        );

        return Array.from(checked).map(item => item.value);
    }

    function beforeDelete() {
        const categories = getSelectedCategories();

        if (categories.length === 0) {
            alert('请先选择需要处理的分类');
            return;
        }

        const message =
            '准备处理以下分类：\n\n' +
            categories.join('\n') +
            '\n\n下一阶段将增加关联文章和图片检测。';

        alert(message);
    }

    window.adminCategory = {
        getSelectedCategories,
        beforeDelete
    };
})();
