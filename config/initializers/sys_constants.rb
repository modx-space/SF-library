# encoding: UTF-8
USER_PER_PAGE=10
BOOK_PER_PAGE=10
DEFAULT_PASSWORD = '123456'
BORROW_STATUSES = ['未出库', '借阅中', '已归还']
ORDER_STATUSES = ['排队中', '已处理']
Time::DATE_FORMATS[:Y_m_D] = '%Y-%m-%d'
Time::DATE_FORMATS[:Y_m_D_H_M] = '%Y-%m-%d %H:%M'
BORROW_PERIOD = 2.weeks